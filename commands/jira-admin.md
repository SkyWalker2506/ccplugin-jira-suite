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
curl -s -u "$JIRA_AUTH" -X POST "${JIRA_URL}/rest/api/3/project" \
  -H "Content-Type: application/json" \
  -d '{
    "key": "<KEY>",
    "name": "<NAME>",
    "projectTypeKey": "software",
    "leadAccountId": "'$LEAD_ID'",
    "projectTemplateKey": "com.pyxis.greenhopper.jira:gh-simplified-agility-kanban"
  }'
```

Show the result. If 201, report success with the project URL.

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
If missing, guide the user through setup (see Prerequisites above).
If present, verify by calling `/rest/api/3/myself` and showing the result.

## Routing

Based on `$ARGUMENTS`:
- Contains "create-project" or "proje oluştur" → create-project flow
- Contains "move-issue" or "taşı" → move-issue flow
- Contains "setup" or "token" or "login" → setup-token flow
- Empty → show available operations
