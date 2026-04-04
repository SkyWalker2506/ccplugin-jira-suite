---
name: jira-run-detailed
description: "Deep Jira board audit and maintenance — routing, quality, suggestions, fixes. Focus is parametric."
allowed-tools: ["Bash", "Read", "Write", "Edit", "Grep", "Glob", "mcp__atlassian__*"]
argument-hint: "[focus] — security, ux, performance, tech-debt, test-coverage, accessibility, analytics, l10n, monetization, offline"
---

## What it does

Background agent performs a **single-pass** deep audit and maintenance of the entire Jira board. Reads every card in depth, fixes issues, makes suggestions.

**Scope (all in one run):**

1. **Board routing & cleanup** — fix cards in wrong status, clean stale IP
2. **Card quality control** — description, acceptance criteria, priority, labels
3. **Card fixes** — complete missing descriptions, fix wrong priority/labels
4. **WAITING/BLOCKED analysis** — why blocked, resolution suggestions
5. **New task suggestions** — missing features, UX, tech debt, test coverage
6. **Priority ordering** — recommended work order

**If focus is provided**, audit from that perspective. **If not**, general audit + maintenance.

## Arguments

| Input | Behavior |
|-------|----------|
| `/jira-run-detailed` | General audit + maintenance |
| `/jira-run-detailed security` | OWASP, API keys, security |
| `/jira-run-detailed ux` | UX flows |
| `/jira-run-detailed performance` | Performance |
| `/jira-run-detailed tech-debt` | Technical debt |
| `/jira-run-detailed test-coverage` | Test coverage |
| `/jira-run-detailed accessibility` | WCAG, a11y |
| `/jira-run-detailed analytics` | Analytics strategy |
| `/jira-run-detailed l10n` | Multi-language, RTL |
| `/jira-run-detailed monetization` | Premium, IAP |
| `/jira-run-detailed offline` | Offline sync |
| Any other topic | Focus on that topic |

## Execution

**Model:** Opus — background agent.

**Single pass:** Not a loop, a one-time deep analysis + maintenance.

Main session starts the agent:

```python
Agent(
  prompt=<template below>,
  model="opus",
  run_in_background=True,
  description="jira-run-detailed audit"
)
```

### Agent prompt template

```
You are a Jira expert consultant. Analyze the project in depth AND perform maintenance.

Read the project's docs/CLAUDE_JIRA.md for project key, cloudId, JQL queries.

FOCUS: [user-provided focus if any, otherwise "General audit + maintenance"]

## STEPS

### 1. Fetch ALL active cards (excluding Done)
Use JQL queries from docs/CLAUDE_JIRA.md.
Fallback JQL: project = PROJECT_KEY AND status != Done

### 2. Read DETAILS of each card (getJiraIssue)
Description, acceptance criteria, comments, labels, priority, subtask relations.

### 3. BOARD ROUTING & CLEANUP (apply immediately)
- Stale IP cards (no lock, >1 hour) -> move to WAITING or To Do
- Cards in wrong status -> correct transition
- Parent with all subtasks Done -> move to Done
- Duplicates -> lower priority to Backlog or close
- Label inconsistencies -> fix

### 4. CARD QUALITY CONTROL & FIXES (apply immediately)
For each card, check and fix with editJiraIssue if needed:
- Missing/insufficient description -> complete (tasks, technical notes)
- No acceptance criteria -> add
- Wrong priority (e.g. critical bug at Low) -> fix
- Missing/wrong labels -> fix
- Estimate too large -> suggest splitting (note in description)

### 5. WAITING/BLOCKED ANALYSIS
- Why waiting? Still valid?
- Resolution suggestion (add as comment)
- Cards that can be unblocked -> move to To Do

### 6. NEW TASK SUGGESTIONS (report only, do not create)
From focus perspective (or general):
- Missing features
- UX improvements
- Technical debt
- Test coverage gaps
- Performance / accessibility
Each suggestion: title, brief description, priority, estimated effort

### 7. PRIORITY ORDER SUGGESTION
What order should current To Do cards be worked on and why.

### 8. WRITE REPORT (as output)

## RULES
- Do NOT touch Done cards
- Do NOT create new tasks — only suggest (user approves later)
- DO fix description/label/priority on existing cards (editJiraIssue)
- DO perform status transitions (for routing/cleanup)
- Do NOT write code or edit files
- Write report detailed but readable
```

## Output

When the agent completes, the main session:

1. Shows the report to the user
2. Summarizes fixes made
3. If there are new task suggestions, offers **3 options**:

```
What should we do?
  1) Create as Jira tasks (creates approved ones in WAITING FOR APPROVAL)
  2) Save as notes (adds to docs/recommendations.md, no Jira changes)
  3) Do nothing (report is informational only)
```
