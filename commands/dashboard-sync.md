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

### 0.5. Sprint Detection (optional)

If the project uses sprints, detect the active sprint:
- JQL: `project = {KEY} AND sprint in openSprints()`
- Add sprint info to cache under `"sprint"` key:
  ```json
  "sprint": {"name": "Sprint 3", "id": 42, "state": "active"}
  ```
- If no active sprint found, set `"sprint": null`

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
  "sprint": {"name": "Sprint 3", "id": 42, "state": "active"},
  "summary": {"total": N, "todo": N, "in_progress": N, "waiting": N, "blocked": N, "backlog": N, "done": N},
  "todo": [{"key": "PROJECT-XX", "summary": "...", "priority": "High", "labels": [...]}],
  "in_progress": [...],
  "waiting": [...],
  "blocked": [...],
  "backlog": [...],
  "done_recent": [{"key": "PROJECT-XX", "summary": "..."}]
}
```

Status mapping is centralized in `scripts/status_map.py` (`STATUS_MAP` dict).
Use `map_status(jira_status)` to convert any Jira status string to its internal key.
`"Done"` maps to `done_recent` (last 10).

### 2.5. Cache schema validation

Before rendering, validate the written cache:

```python
import json
from pathlib import Path

REQUIRED_KEYS = ["version", "updated", "summary"]
REQUIRED_SUMMARY_KEYS = ["total", "todo", "in_progress", "done"]
MIN_VERSION = 2

def validate_cache(cache_path=".jira_cache.json"):
    if not Path(cache_path).exists():
        return False, "Cache file missing"
    try:
        data = json.loads(Path(cache_path).read_text())
    except json.JSONDecodeError as e:
        return False, f"Cache is not valid JSON: {e}"
    
    for key in REQUIRED_KEYS:
        if key not in data:
            return False, f"Cache missing required key: '{key}'"
    
    version = data.get("version", 0)
    if version < MIN_VERSION:
        return False, f"Cache version {version} is outdated (min: {MIN_VERSION})"
    
    summary = data.get("summary", {})
    for key in REQUIRED_SUMMARY_KEYS:
        if key not in summary:
            return False, f"Cache summary missing key: '{key}'"
    
    return True, "ok"
```

If validation fails:
```
✗ Cache validation failed: {reason}
  Run /dashboard-sync to regenerate.
```
Stop — do not attempt to render a broken cache.

If validation passes: proceed silently to render.

### 3. Render dashboard

```bash
python3 scripts/dashboard.py
```

After output, do NOT add extra commentary.
