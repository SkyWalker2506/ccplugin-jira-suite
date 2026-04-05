---
name: dashboard-sync
description: "Fetch fresh data from Jira MCP, write to cache, then render dashboard."
allowed-tools: ["Bash", "Read", "Write", "mcp__atlassian__*"]
argument-hint: "no arguments"
---

## What it does

Pull fresh data from Jira via MCP, write to `.jira_cache.json`, then render the dashboard.

## Execution

### 0. MCP Connection Check

Before fetching data, verify Atlassian MCP is accessible:
- Call `getAccessibleAtlassianResources` 
- If it fails or returns empty: show error and exit
  ```
  ✗ Atlassian MCP not connected. Check .mcp.json configuration.
  ```
- If successful: proceed to fetch

### 1. Fetch from Jira (2 parallel calls)

Read project key from `docs/CLAUDE_JIRA.md` or `CLAUDE.md` (e.g. VOC, AC, TASK).

- **Not-done:** `project = {KEY} AND status NOT IN ("Done") ORDER BY status ASC, priority DESC` — fields: summary, status, priority, labels — max 50
- **Done:** `project = {KEY} AND status = "Done" ORDER BY updated DESC` — fields: summary, status, priority — max 10

If results are large and saved to file, parse with python3.

### 2. Write cache

Parse results and write to `.jira_cache.json`:

```json
{
  "version": 2,
  "updated": "<ISO timestamp>",
  "summary": {"total": N, "todo": N, "in_progress": N, "waiting": N, "blocked": N, "backlog": N, "done": N},
  "todo": [{"key": "PROJECT-XX", "summary": "...", "priority": "High", "labels": [...]}],
  "in_progress": [...],
  "waiting": [...],
  "blocked": [...],
  "backlog": [...],
  "done_recent": [{"key": "PROJECT-XX", "summary": "..."}]
}
```

Status mapping:
- `"To Do"` -> todo
- `"In Progress"` -> in_progress
- `"WAITING FOR APPROVAL"` -> waiting
- `"BLOCKED"` -> blocked
- `"BACKLOG"` -> backlog
- `"Done"` -> done_recent (last 10)

### 3. Render dashboard

```bash
python3 scripts/dashboard.py
```

After output, do NOT add extra commentary.
