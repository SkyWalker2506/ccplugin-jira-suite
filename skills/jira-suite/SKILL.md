---
name: jira-suite
description: "Auto-trigger skill for Jira and sprint management. Routes to the appropriate command based on user intent."
---

## Trigger

Activates when user mentions any of:
- jira, sprint, board, kanban, scrum, agile
- task management, backlog, standup, retro
- "show my tasks", "what's in progress", "waiting cards"
- "start a task", "run the loop", "cancel jira"
- dashboard, board overview, sprint status

## Behavior

When triggered, determine intent and suggest or invoke the appropriate command:

| User intent | Command |
|-------------|---------|
| Run Jira check loop | `/jira-run` |
| Run fast loop (1s intervals) | `/jira-run-fast` |
| Deep board audit / maintenance | `/jira-run-detailed` |
| Stop the running loop | `/jira-cancel` |
| Pick tasks and start coding pipeline | `/jira-start-new-task` |
| Review WAITING cards, make decisions | `/decide` |
| Quick board overview (from cache) | `/dashboard` |
| Refresh board data and show dashboard | `/dashboard-sync` |

## Routing rules

1. If intent is clear, invoke the command directly.
2. If ambiguous, show a short menu of matching commands with one-line descriptions.
3. Always read `docs/CLAUDE_JIRA.md` for project key and configuration before making Jira API calls.
4. If Atlassian MCP is not connected, warn the user and suggest checking MCP configuration.

## Prerequisites

- Atlassian MCP server must be configured and connected
- Project must have `docs/CLAUDE_JIRA.md` with project key, cloudId, and JQL queries
