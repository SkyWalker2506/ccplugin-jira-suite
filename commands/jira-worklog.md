---
name: jira-worklog
description: "Add worklog entry to a Jira issue — time spent, optional description."
allowed-tools: ["Bash", "Read", "mcp__atlassian__addWorklogToJiraIssue", "mcp__atlassian__getJiraIssue"]
argument-hint: "<ISSUE_KEY> <time> [description] — e.g. JS-10 2h 'Fixed login bug'"
---

## What it does

Log time spent on a Jira issue.

## Arguments

| Input | Behavior |
|-------|----------|
| `JS-10 2h` | Log 2 hours on JS-10 |
| `JS-10 30m "Fixed auth bug"` | Log 30 min with description |
| `JS-10 1d` | Log 1 day (8h) on JS-10 |
| `JS-10 1h30m` | Log 1.5 hours |

## Execution

### 1. Parse arguments
- ISSUE_KEY: first token (validate with regex)
- Time: second token — parse to seconds
  - `Xh` = X * 3600
  - `Xm` = X * 60
  - `Xd` = X * 28800 (8h workday)
  - `XhYm` = compound
- Description: remaining tokens (optional)

### 2. Add worklog
Call `addWorklogToJiraIssue` with:
- issueIdOrKey: ISSUE_KEY
- timeSpentSeconds: calculated seconds
- comment (if description provided)

### 3. Confirm
```
✓ JS-10: logged 2h (7200s)
  Total logged: 5h 30m
```

Show current total from issue's timetracking field if available.
