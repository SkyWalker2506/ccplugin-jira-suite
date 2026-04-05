# Shared State Schema — .jira-state/

## Directory Structure

```
.jira-state/
├── jira-run.stop          # Stop file — presence cancels jira-run loop
├── working-{KEY}-XX.lock  # Task-level working lock
└── file-locks/            # File-level locks for multi-agent safety
    └── {encoded-path}.lock
```

## Files

### jira-run.stop
- **Purpose:** Signal to stop the jira-run loop
- **Created by:** `/jira-cancel` command
- **Read by:** `/jira-run` at the start of each round
- **Format:** Empty file (presence = stop signal)
- **Lifecycle:** Created on cancel, deleted on next jira-run start

### working-{ISSUE_KEY}.lock
- **Purpose:** Mark a task as actively being worked on by an agent
- **Created by:** `run_task_agent.sh` on pipeline start
- **Format:** `{ISSUE_KEY} {unix_timestamp}`
- **Stale threshold:** 15 minutes (900 seconds)
- **Cleanup:** Auto-removed on process exit via trap

### file-locks/{encoded-path}.lock
- **Purpose:** Prevent concurrent file edits by multiple agents
- **Created by:** Implementation agents before editing files
- **Format:** `{ISSUE_KEY} {unix_timestamp}`
- **Path encoding:** `/` replaced with `__` (e.g., `src__main.py` → `src__main.py.lock`)
- **TTL:** 600 seconds (10 minutes)
- **Cleanup:** Removed after commit+push, or on process exit via trap

## Cache Files (project root)

### .jira_cache.json
- **Purpose:** Cached board state for zero-token dashboard
- **Created by:** `/dashboard-sync`
- **Read by:** `/dashboard` (via `scripts/dashboard.py`)
- **Format:** See dashboard-sync.md for schema
- **Refresh:** Manual via `/dashboard-sync`

## Gitignore

All state files are excluded via `.gitignore`:
```
.jira-state/
.jira_cache.json
```
