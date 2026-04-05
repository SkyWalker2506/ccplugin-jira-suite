---
name: jira-report
description: "Generate sprint reports — completed count, velocity, status breakdown, sprint health."
allowed-tools: ["Bash", "Read", "Write", "mcp__atlassian__searchJiraIssuesUsingJql", "mcp__atlassian__getJiraIssue"]
argument-hint: "[type] — summary | velocity | done | full (default: summary)"
---

## What it does

Generate reports about the current sprint and project health.

## Arguments

| Input | Report |
|-------|--------|
| `/jira-report` or `summary` | Quick status breakdown |
| `/jira-report velocity` | Sprint velocity (done per sprint) |
| `/jira-report done` | Recently completed issues |
| `/jira-report full` | All reports combined |

## Execution

### Summary Report
Fetch all non-done issues + recently done. Output:
```
SPRINT REPORT — {PROJECT_KEY}
Generated: {timestamp}

Status Breakdown:
  In Progress:  ██████░░░░  3
  To Do:        ████░░░░░░  2
  Waiting:      ██░░░░░░░░  1
  Blocked:      ░░░░░░░░░░  0
  Done (recent): ████████░░  4

Total Active: 6 | Done (last 7d): 4
Health: 🟢 On track
```

Health indicator:
- 🟢 blocked=0, waiting≤1
- 🟡 blocked=1 or waiting=2-3
- 🔴 blocked≥2 or waiting≥4

### Velocity Report
Query done issues grouped by week:
```
VELOCITY — {PROJECT_KEY}

  Week 14 (Mar 31):  ████████  8 issues
  Week 13 (Mar 24):  ██████    6 issues
  Week 12 (Mar 17):  ██████████ 10 issues

  Avg: 8.0 issues/week
```

### Done Report
List recently completed issues (last 14 days):
```
COMPLETED — {PROJECT_KEY} (last 14 days)

  JS-42  Fix login validation        2026-04-04  #security
  JS-41  Add retry logic             2026-04-03  #arch
  ...
  Total: 12 issues
```

### Full Report
Combines all three reports above.

## Output
Display in terminal with colors (use ANSI codes). Do NOT write to file unless user requests it.
