---
name: jira
description: "Intent-based command router — suggest the right jira-suite command based on natural language input."
allowed-tools: ["Bash", "Read"]
argument-hint: "[intent] — e.g. 'show board', 'start task', 'link issue', 'run loop'"
---

## What it does

When a user types `/jira` with a description of what they want to do, suggest and optionally run the most relevant jira-suite command.

## Command Map

| Intent keywords | Command |
|----------------|---------|
| show, board, dashboard, status, overview | `/dashboard` |
| sync, refresh, fetch, update cache | `/dashboard-sync` |
| run, loop, automate, watch, patrol | `/jira-run` |
| cancel, stop, halt loop | `/jira-cancel` |
| start task, pick task, work on, implement | `/jira-start-new-task` |
| link, relate, blocks, blocked by, depends | `/jira-link` |
| log time, worklog, time spent, hours | `/jira-worklog` |
| report, velocity, burndown, completed, metrics | `/jira-report` |
| switch project, change project | `/jira-switch` |
| admin, create project, setup columns, setup token | `/jira-admin` |
| init, initialize, setup project | `/jira-init` |
| decide, waiting, review queue, approve | `/decide` |

## Execution

1. Parse `$ARGUMENTS` for intent keywords (case-insensitive)
2. Match against the table above
3. If match found:
   - Show: `Suggested: /<command> — <one-line description>`
   - Ask: "Run it now? (yes/no)"
   - If yes or arguments clearly indicate action: run it
4. If no match or empty arguments:
   - Show full command list:

```
jira-suite commands:
  /dashboard          — View board status (cached)
  /dashboard-sync     — Fetch fresh data and render board
  /jira-run           — Start automated loop
  /jira-cancel        — Stop running loop
  /jira-start-new-task — Pick & implement next task
  /jira-link          — Link issues (blocks/relates-to)
  /jira-worklog       — Log time on an issue
  /jira-report        — Sprint reports & velocity
  /jira-switch        — Switch active project
  /jira-admin         — Admin operations (create project, columns)
  /jira-init          — Initialize project config
  /decide             — Review WAITING queue

Type /jira <intent> to get a suggestion, e.g.:
  /jira show board
  /jira link JS-10 blocks JS-15
  /jira log 2h on JS-20
```

## Examples

| Input | Output |
|-------|--------|
| `/jira show board` | Suggests `/dashboard` |
| `/jira start a task` | Suggests `/jira-start-new-task` |
| `/jira link JS-5 blocks JS-8` | Runs `/jira-link JS-5 blocks JS-8` directly |
| `/jira log 2h on JS-10` | Runs `/jira-worklog JS-10 2h` |
| `/jira` | Shows full command list |
