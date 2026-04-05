---
name: jira-admin
description: "Jira admin operations — create projects, move issues, setup columns. Requires API token in secrets."
allowed-tools: ["Bash", "Read", "Write", "Edit"]
argument-hint: "[create-project|move-issue|setup-token|setup-columns] [args...]"
---

# Jira Admin

Admin operations that the Atlassian MCP doesn't support yet. Uses Jira REST API directly via curl.

## Prerequisites

Requires `JIRA_URL`, `JIRA_EMAIL`, `JIRA_API_TOKEN` in `~/.claude/secrets/secrets.env`.

If missing, run `setup-token` operation below.

## Helper

All operations use:
```bash
source ~/.claude/secrets/secrets.env 2>/dev/null

# Dependency check
for cmd in python3 curl; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "❌ Required dependency missing: $cmd"; exit 1; }
done

# Auth header (avoids token exposure in ps aux — unlike curl -u)
JIRA_AUTH_HEADER="Authorization: Basic $(printf '%s' "${JIRA_EMAIL:-$JIRA_USERNAME}:${JIRA_API_TOKEN}" | base64)"
```

### Input validation

```bash
validate_project_key() {
  [[ "$1" =~ ^[A-Z][A-Z0-9]{1,9}$ ]] || { echo "❌ Invalid PROJECT_KEY: '$1' (must match [A-Z][A-Z0-9]{1,9})"; exit 1; }
}

validate_issue_key() {
  [[ "$1" =~ ^[A-Z][A-Z0-9]{1,9}-[0-9]+$ ]] || { echo "❌ Invalid ISSUE_KEY: '$1' (must match KEY-123)"; exit 1; }
}
```

---

## Column Templates

Used by both `create-project` and `setup-columns`. Select based on project type.

Column templates are defined in `templates/columns.json`. Load with:
```bash
# Validate TEMPLATE before interpolation into Python (whitelist: lowercase letters, digits, hyphens, underscores; max 20 chars)
TEMPLATE="${TEMPLATE:-software}"
if [[ ! "$TEMPLATE" =~ ^[a-z][a-z0-9_-]{0,19}$ ]]; then
  echo "❌ Invalid TEMPLATE value: '$TEMPLATE' (must match ^[a-z][a-z0-9_-]{0,19}$)"
  exit 1
fi
COLUMNS=$(python3 -c "import json; print('\n'.join(json.load(open('templates/columns.json'))['${TEMPLATE}']))")
```

Available templates: `base`, `software` (default), `mobile`, `ai-ml`, `saas`, `bot`, `ideas`, `minimal`.

When user doesn't specify a type, ask or default to `software`.

---

## Operations

### `create-project <KEY> <NAME> [--type <template>]`

```bash
source ~/.claude/secrets/secrets.env 2>/dev/null
JIRA_AUTH_HEADER="Authorization: Basic $(printf '%s' "${JIRA_EMAIL:-$JIRA_USERNAME}:${JIRA_API_TOKEN}" | base64)"

validate_project_key "<KEY>"

# Get lead account ID
LEAD_ID=$(curl -s -H "$JIRA_AUTH_HEADER" "${JIRA_URL}/rest/api/3/myself" | \
  python3 -c "import json,sys; print(json.load(sys.stdin)['accountId'])")

# Create project
RESULT=$(curl -s -w "\n%{http_code}" -H "$JIRA_AUTH_HEADER" -X POST "${JIRA_URL}/rest/api/3/project" \
  -H "Content-Type: application/json" \
  -d '{
    "key": "<KEY>",
    "name": "<NAME>",
    "projectTypeKey": "software",
    "leadAccountId": "'"$LEAD_ID"'",
    "projectTemplateKey": "com.pyxis.greenhopper.jira:gh-simplified-agility-kanban"
  }')
HTTP_CODE=$(echo "$RESULT" | tail -1)
BODY=$(echo "$RESULT" | sed '$d')

if [ "$HTTP_CODE" != "201" ]; then
  echo "❌ Project creation failed (HTTP $HTTP_CODE): $BODY"
  exit 1
fi

PROJECT_ID=$(echo "$BODY" | python3 -c "import json,sys; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
```

Apply column template (default: `software`):

```bash
BOARD_ID=$(curl -s -H "$JIRA_AUTH_HEADER" "${JIRA_URL}/rest/agile/1.0/board?projectKeyOrId=<KEY>" | \
  python3 -c "import json,sys; d=json.load(sys.stdin); print(d['values'][0]['id'] if d.get('values') else '')" 2>/dev/null)

# Apply selected template — column names escaped to prevent JSON injection
for COL in "${COLUMNS[@]}"; do
  ESCAPED=$(python3 -c "import json,sys; print(json.dumps(sys.argv[1]))" "$COL")
  curl -s -H "$JIRA_AUTH_HEADER" -X POST "${JIRA_URL}/rest/agile/1.0/board/${BOARD_ID}/column" \
    -H "Content-Type: application/json" \
    -d "{\"name\": $ESCAPED}" > /dev/null
done
```

Report: project URL + template used + columns created.

---

### `setup-columns <PROJECT_KEY> [--type <template>]`

Add columns to an **existing** project. Skips columns that already exist.

```bash
source ~/.claude/secrets/secrets.env 2>/dev/null
source "$(dirname "$0")/../scripts/retry.sh"
JIRA_AUTH_HEADER="Authorization: Basic $(printf '%s' "${JIRA_EMAIL:-$JIRA_USERNAME}:${JIRA_API_TOKEN}" | base64)"

validate_project_key "<PROJECT_KEY>"

# curl wrapper with HTTP 429 rate-limit handling (exponential backoff, max 4 attempts)
curl_with_retry() {
  local attempt=0 delay=2 http_code body result
  while [ $attempt -lt 4 ]; do
    result=$(curl -s -w "\n%{http_code}" "$@")
    http_code=$(printf '%s' "$result" | tail -1)
    body=$(printf '%s' "$result" | sed '$d')
    if [ "$http_code" = "429" ]; then
      attempt=$((attempt + 1))
      if [ $attempt -lt 4 ]; then
        echo "[rate-limit] HTTP 429 — waiting ${delay}s before retry $attempt/3..." >&2
        sleep $delay
        delay=$((delay * 2))
      else
        echo "[rate-limit] HTTP 429 — all retries exhausted." >&2
        printf '%s\n%s' "$body" "$http_code"
        return 1
      fi
    else
      printf '%s\n%s' "$body" "$http_code"
      return 0
    fi
  done
}

# Find board
BOARD_RESULT=$(curl_with_retry -H "$JIRA_AUTH_HEADER" "${JIRA_URL}/rest/agile/1.0/board?projectKeyOrId=<PROJECT_KEY>")
BOARD_HTTP=$(printf '%s' "$BOARD_RESULT" | tail -1)
BOARD_BODY=$(printf '%s' "$BOARD_RESULT" | sed '$d')
if [ "$BOARD_HTTP" = "429" ]; then echo "❌ Rate limited fetching board — aborting."; exit 1; fi
BOARD_ID=$(printf '%s' "$BOARD_BODY" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['values'][0]['id'] if d.get('values') else '')")

# Get existing columns (to skip duplicates)
CFG_RESULT=$(curl_with_retry -H "$JIRA_AUTH_HEADER" "${JIRA_URL}/rest/agile/1.0/board/${BOARD_ID}/configuration")
CFG_HTTP=$(printf '%s' "$CFG_RESULT" | tail -1)
CFG_BODY=$(printf '%s' "$CFG_RESULT" | sed '$d')
if [ "$CFG_HTTP" = "429" ]; then echo "❌ Rate limited fetching columns — aborting."; exit 1; fi
EXISTING=$(printf '%s' "$CFG_BODY" | python3 -c "import json,sys; d=json.load(sys.stdin); [print(c['name']) for c in d.get('columnConfig',{}).get('columns',[])]")

# Add only missing columns — column names escaped to prevent JSON injection
for COL in "${COLUMNS[@]}"; do
  if echo "$EXISTING" | grep -qx "$COL"; then
    echo "  ⏭  $COL (already exists)"
  else
    ESCAPED=$(python3 -c "import json,sys; print(json.dumps(sys.argv[1]))" "$COL")
    ADD_RESULT=$(curl_with_retry -H "$JIRA_AUTH_HEADER" \
      -X POST "${JIRA_URL}/rest/agile/1.0/board/${BOARD_ID}/column" \
      -H "Content-Type: application/json" \
      -d "{\"name\": $ESCAPED}")
    RES=$(printf '%s' "$ADD_RESULT" | tail -1)
    [ "$RES" = "200" ] || [ "$RES" = "201" ] && echo "  ✅ $COL" || echo "  ❌ $COL ($RES)"
  fi
done
```

Note: Column **ordering** is not supported by Jira REST API — must be done manually via Board Settings → Columns in Jira UI.

---

### `move-issue <ISSUE_KEY> <TARGET_PROJECT_KEY>`

```bash
source ~/.claude/secrets/secrets.env 2>/dev/null
JIRA_AUTH_HEADER="Authorization: Basic $(printf '%s' "${JIRA_EMAIL:-$JIRA_USERNAME}:${JIRA_API_TOKEN}" | base64)"

validate_issue_key "<ISSUE_KEY>"
validate_project_key "<TARGET_PROJECT_KEY>"

PROJECT_ID=$(curl -s -H "$JIRA_AUTH_HEADER" "${JIRA_URL}/rest/api/3/project/<TARGET_PROJECT_KEY>" | \
  python3 -c "import json,sys; print(json.load(sys.stdin)['id'])")

curl -s -H "$JIRA_AUTH_HEADER" -X PUT "${JIRA_URL}/rest/api/3/issue/<ISSUE_KEY>" \
  -H "Content-Type: application/json" \
  -d '{"fields": {"project": {"id": "'$PROJECT_ID'"}}}'
```

Report old key → new key mapping.

---

### `setup-token`

Check if JIRA_URL, JIRA_EMAIL, JIRA_API_TOKEN exist in `~/.claude/secrets/secrets.env`.

**If missing or incomplete:**
1. Open token page in browser:
```bash
open "https://id.atlassian.com/manage-profile/security/api-tokens" 2>/dev/null || \
xdg-open "https://id.atlassian.com/manage-profile/security/api-tokens" 2>/dev/null || true
```
2. Open secrets file in editor:
```bash
SECRETS_FILE="$HOME/.claude/secrets/secrets.env"
mkdir -p "$(dirname "$SECRETS_FILE")"
touch "$SECRETS_FILE"
chmod 600 "$SECRETS_FILE"
open -e "$SECRETS_FILE" 2>/dev/null || ${EDITOR:-nano} "$SECRETS_FILE" 2>/dev/null || xdg-open "$SECRETS_FILE" 2>/dev/null || true
```
3. Tell user: "Token page and secrets file opened. Add your token, then run again."

**If all present:**
1. Ensure file permissions: `chmod 600 "$SECRETS_FILE"`
2. Verify via `/rest/api/3/myself` (using header auth, not `-u`), show display name + email.
3. Record token creation date in secrets file (only if not already present):
```bash
if ! grep -q "^# TOKEN_CREATED=" "$SECRETS_FILE" 2>/dev/null; then
  echo "# TOKEN_CREATED=$(date +%Y-%m-%d)" >> "$SECRETS_FILE"
  echo "  ✅ TOKEN_CREATED recorded in secrets.env"
fi
```

---

## Routing

Based on `$ARGUMENTS`:
- `create-project` or "create project" → create-project flow
- `setup-columns` or "add columns" or "kolon ekle" → setup-columns flow
- `move-issue` or "move" or "taşı" → move-issue flow
- `setup` or `token` or `login` → setup-token flow
- Empty → list available operations with examples

## Audit Logging

All admin operations are logged to `docs/audit_log.md`. Each operation sources `scripts/audit-log.sh` and calls:
```bash
source "$(dirname "$0")/audit-log.sh"
audit_log "<operation>" "<details>"
```
