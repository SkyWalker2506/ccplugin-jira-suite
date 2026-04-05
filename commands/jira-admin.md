---
name: jira-admin
description: "Jira admin operations — create projects, move issues. Requires API token in secrets."
allowed-tools: ["Bash", "Read", "Write", "Edit"]
argument-hint: "[create-project|move-issue|setup-token] [args...]"
---

# Jira Admin

Admin operations that the Atlassian MCP doesn't support yet. Uses Jira REST API directly via curl.

## Prerequisites

Requires `JIRA_URL`, `JIRA_EMAIL`, `JIRA_API_TOKEN` in `~/.claude/secrets/secrets.env`.

If missing, guide the user:
1. Go to https://id.atlassian.com/manage-profile/security/api-tokens
2. Create a new API token
3. Add to `~/.claude/secrets/secrets.env`:
```
JIRA_URL=https://yoursite.atlassian.net
JIRA_EMAIL=your@email.com
JIRA_API_TOKEN=your-token
```

## Helper function

All operations use this base:
```bash
source ~/.claude/secrets/secrets.env 2>/dev/null
JIRA_AUTH="${JIRA_EMAIL:-$JIRA_USERNAME}:${JIRA_API_TOKEN}"
```

## Operations

### `create-project <KEY> <NAME>`

```bash
source ~/.claude/secrets/secrets.env 2>/dev/null
JIRA_AUTH="${JIRA_EMAIL:-$JIRA_USERNAME}:${JIRA_API_TOKEN}"

# Get lead account ID
LEAD_ID=$(curl -s -u "$JIRA_AUTH" "${JIRA_URL}/rest/api/3/myself" | python3 -c "import json,sys; print(json.load(sys.stdin)['accountId'])")

# Create project
RESULT=$(curl -s -w "\n%{http_code}" -u "$JIRA_AUTH" -X POST "${JIRA_URL}/rest/api/3/project" \
  -H "Content-Type: application/json" \
  -d '{
    "key": "<KEY>",
    "name": "<NAME>",
    "projectTypeKey": "software",
    "leadAccountId": "'$LEAD_ID'",
    "projectTemplateKey": "com.pyxis.greenhopper.jira:gh-simplified-agility-kanban"
  }')
HTTP_CODE=$(echo "$RESULT" | tail -1)
BODY=$(echo "$RESULT" | head -1)
PROJECT_ID=$(echo "$BODY" | python3 -c "import json,sys; print(json.load(sys.stdin).get('id',''))" 2>/dev/null)
```

If HTTP 201 and PROJECT_ID obtained, create columns via board API:

```bash
# Find board ID for the new project
BOARD_ID=$(curl -s -u "$JIRA_AUTH" "${JIRA_URL}/rest/agile/1.0/board?projectKeyOrId=<KEY>" | \
  python3 -c "import json,sys; d=json.load(sys.stdin); print(d['values'][0]['id'] if d.get('values') else '')" 2>/dev/null)

# Default columns for a software project (10 columns)
COLUMNS=("Backlog" "To Do" "In Progress" "WAITING" "Blocked" "Review" "Testing" "Done" "Released" "Cancelled")

for COL in "${COLUMNS[@]}"; do
  curl -s -u "$JIRA_AUTH" -X POST "${JIRA_URL}/rest/agile/1.0/board/${BOARD_ID}/column" \
    -H "Content-Type: application/json" \
    -d '{"name": "'"$COL"'"}' > /dev/null
done
```

Report: project URL `${JIRA_URL}/jira/software/projects/<KEY>/boards` + columns created.

### `move-issue <ISSUE_KEY> <TARGET_PROJECT_KEY>`

```bash
source ~/.claude/secrets/secrets.env 2>/dev/null
JIRA_AUTH="${JIRA_EMAIL:-$JIRA_USERNAME}:${JIRA_API_TOKEN}"

# Get target project ID
PROJECT_ID=$(curl -s -u "$JIRA_AUTH" "${JIRA_URL}/rest/api/3/project/<TARGET_PROJECT_KEY>" | python3 -c "import json,sys; print(json.load(sys.stdin)['id'])")

# Move issue by updating project field
curl -s -u "$JIRA_AUTH" -X PUT "${JIRA_URL}/rest/api/3/issue/<ISSUE_KEY>" \
  -H "Content-Type: application/json" \
  -d '{"fields": {"project": {"id": "'$PROJECT_ID'"}}}'
```

Report old key → new key mapping.

### `setup-token`

Check if JIRA_URL, JIRA_EMAIL, JIRA_API_TOKEN exist in `~/.claude/secrets/secrets.env`.

**If missing or incomplete:**
1. Open the API token page in browser:
```bash
# macOS
open "https://id.atlassian.com/manage-profile/security/api-tokens" 2>/dev/null || \
# Linux
xdg-open "https://id.atlassian.com/manage-profile/security/api-tokens" 2>/dev/null || true
```
2. Open the secrets file in editor:
```bash
SECRETS_FILE="$HOME/.claude/secrets/secrets.env"
mkdir -p "$(dirname "$SECRETS_FILE")"
touch "$SECRETS_FILE"
# macOS
open -e "$SECRETS_FILE" 2>/dev/null || \
# Linux/fallback
${EDITOR:-nano} "$SECRETS_FILE" 2>/dev/null || \
xdg-open "$SECRETS_FILE" 2>/dev/null || true
```
3. Tell user: "Tarayıcıda token sayfasını ve secrets.env dosyasını açtım. Token oluşturduktan sonra secrets.env'e ekle, sonra tekrar çalıştır."

**If all present:** verify by calling `/rest/api/3/myself` and showing display name + email.

## Routing

Based on `$ARGUMENTS`:
- Contains "create-project" or "proje oluştur" → create-project flow
- Contains "move-issue" or "taşı" → move-issue flow
- Contains "setup" or "token" or "login" → setup-token flow
- Empty → show available operations
