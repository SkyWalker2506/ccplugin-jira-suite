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
JIRA_AUTH="${JIRA_EMAIL:-$JIRA_USERNAME}:${JIRA_API_TOKEN}"
```

---

## Column Templates

Used by both `create-project` and `setup-columns`. Select based on project type.

```
base        → Backlog, To Do, In Progress, Review, Testing, Done, Cancelled
              (universal — works for any project)

software    → base + WAITING, Blocked, Released
              (general software project)

mobile      → software + Beta
              (iOS/Android — TestFlight/internal track stage)

ai-ml       → software + Model Training
              (ML pipelines — training runs separately from development)

saas        → software + Staging, Beta
              (web apps with staged rollout)

bot         → software + Deploying
              (trading bots, automation — live monitoring period)

ideas       → Idea, Evaluating, Parked, Accepted, In Development, Done, Rejected, Archived
              (idea pipeline — not for development tasks)

minimal     → To Do, In Progress, Done
              (simple projects, side projects, experiments)
```

When user doesn't specify a type, ask or default to `software`.

---

## Operations

### `create-project <KEY> <NAME> [--type <template>]`

```bash
source ~/.claude/secrets/secrets.env 2>/dev/null
JIRA_AUTH="${JIRA_EMAIL:-$JIRA_USERNAME}:${JIRA_API_TOKEN}"

# Get lead account ID
LEAD_ID=$(curl -s -u "$JIRA_AUTH" "${JIRA_URL}/rest/api/3/myself" | \
  python3 -c "import json,sys; print(json.load(sys.stdin)['accountId'])")

# Create project
RESULT=$(curl -s -w "\n%{http_code}" -u "$JIRA_AUTH" -X POST "${JIRA_URL}/rest/api/3/project" \
  -H "Content-Type: application/json" \
  -d '{
    "key": "<KEY>",
    "name": "<NAME>",
    "projectTypeKey": "software",
    "leadAccountId": "'"$LEAD_ID"'",
    "projectTemplateKey": "com.pyxis.greenhopper.jira:gh-simplified-agility-kanban"
  }')
HTTP_CODE=$(echo "$RESULT" | tail -1)
BODY=$(echo "$RESULT" | head -1)
PROJECT_ID=$(echo "$BODY" | python3 -c "import json,sys; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
```

If HTTP 201, apply column template (default: `software`):

```bash
BOARD_ID=$(curl -s -u "$JIRA_AUTH" "${JIRA_URL}/rest/agile/1.0/board?projectKeyOrId=<KEY>" | \
  python3 -c "import json,sys; d=json.load(sys.stdin); print(d['values'][0]['id'] if d.get('values') else '')" 2>/dev/null)

# Apply selected template (replace COLUMNS with template list below)
for COL in "${COLUMNS[@]}"; do
  curl -s -u "$JIRA_AUTH" -X POST "${JIRA_URL}/rest/agile/1.0/board/${BOARD_ID}/column" \
    -H "Content-Type: application/json" \
    -d '{"name": "'"$COL"'"}' > /dev/null
done
```

Report: project URL + template used + columns created.

---

### `setup-columns <PROJECT_KEY> [--type <template>]`

Add columns to an **existing** project. Skips columns that already exist.

```bash
source ~/.claude/secrets/secrets.env 2>/dev/null
JIRA_AUTH="${JIRA_EMAIL:-$JIRA_USERNAME}:${JIRA_API_TOKEN}"

# Find board
BOARD_ID=$(curl -s -u "$JIRA_AUTH" "${JIRA_URL}/rest/agile/1.0/board?projectKeyOrId=<PROJECT_KEY>" | \
  python3 -c "import json,sys; d=json.load(sys.stdin); print(d['values'][0]['id'] if d.get('values') else '')")

# Get existing columns (to skip duplicates)
EXISTING=$(curl -s -u "$JIRA_AUTH" "${JIRA_URL}/rest/agile/1.0/board/${BOARD_ID}/configuration" | \
  python3 -c "import json,sys; d=json.load(sys.stdin); [print(c['name']) for c in d.get('columnConfig',{}).get('columns',[])]")

# Add only missing columns
for COL in "${COLUMNS[@]}"; do
  if echo "$EXISTING" | grep -qx "$COL"; then
    echo "  ⏭  $COL (already exists)"
  else
    RES=$(curl -s -o /dev/null -w "%{http_code}" -u "$JIRA_AUTH" \
      -X POST "${JIRA_URL}/rest/agile/1.0/board/${BOARD_ID}/column" \
      -H "Content-Type: application/json" \
      -d '{"name": "'"$COL"'"}')
    [ "$RES" = "200" ] || [ "$RES" = "201" ] && echo "  ✅ $COL" || echo "  ❌ $COL ($RES)"
  fi
done
```

Note: Column **ordering** is not supported by Jira REST API — must be done manually via Board Settings → Columns in Jira UI.

---

### `move-issue <ISSUE_KEY> <TARGET_PROJECT_KEY>`

```bash
source ~/.claude/secrets/secrets.env 2>/dev/null
JIRA_AUTH="${JIRA_EMAIL:-$JIRA_USERNAME}:${JIRA_API_TOKEN}"

PROJECT_ID=$(curl -s -u "$JIRA_AUTH" "${JIRA_URL}/rest/api/3/project/<TARGET_PROJECT_KEY>" | \
  python3 -c "import json,sys; print(json.load(sys.stdin)['id'])")

curl -s -u "$JIRA_AUTH" -X PUT "${JIRA_URL}/rest/api/3/issue/<ISSUE_KEY>" \
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
open -e "$SECRETS_FILE" 2>/dev/null || ${EDITOR:-nano} "$SECRETS_FILE" 2>/dev/null || xdg-open "$SECRETS_FILE" 2>/dev/null || true
```
3. Tell user: "Token page and secrets file opened. Add your token, then run again."

**If all present:** verify via `/rest/api/3/myself`, show display name + email.

---

## Routing

Based on `$ARGUMENTS`:
- `create-project` or "create project" → create-project flow
- `setup-columns` or "add columns" or "kolon ekle" → setup-columns flow
- `move-issue` or "move" or "taşı" → move-issue flow
- `setup` or `token` or `login` → setup-token flow
- Empty → list available operations with examples
