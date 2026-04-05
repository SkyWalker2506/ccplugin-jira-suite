---
name: decide
description: "Quick decision loop for WAITING cards. Plain text list, user picks T/B/W/D per card, transitions applied."
allowed-tools: ["Bash", "Read", "mcp__atlassian__*"]
argument-hint: "[max_count] — e.g. 5 | empty = all WAITING cards"
---

## What it does

Show all WAITING FOR APPROVAL cards in a mouse-selectable plain text list. User responds with quick codes to move them.

## Arguments

| Arg | What |
|-----|------|
| *(empty)* | All WAITING cards |
| `5` | First 5 (by priority) |

## How it works

Runs in main session (interactive — no background agent).

### Step 1: Fetch WAITING cards

Read project key from `docs/CLAUDE_JIRA.md` or `CLAUDE.md`.

JQL: `project = {KEY} AND status = "WAITING FOR APPROVAL" ORDER BY priority DESC`
fields: summary, priority, labels — max 50

### Step 2: Show cards

Plain text, one card per block — easy to mouse-select:

```
 1  {KEY}-XXX  Card title here                          High  #label
    Why waiting: one sentence reason

 2  {KEY}-YYY  Another card title                       Med   #label
    Why waiting: one sentence reason
```

At the bottom show options:

```
T = To Do    B = Backlog    W = Keep waiting    D = Close

Reply examples:
  1T 2T 3B 4W 5D
  1-5T 6-10B
  all T
```

### Step 3: Apply user decisions

Parse user reply. For each card:
- T -> transition To Do (dynamic lookup) + comment "Decide: moved to To Do"
- B -> transition Backlog (dynamic lookup) + comment "Decide: moved to Backlog"
- W -> skip (no change)
- D -> transition Done (dynamic lookup) + comment "Decide: closed"

### Transition Resolution
Do NOT hardcode transition IDs. For each card:
1. Call `getTransitionsForJiraIssue` with the issue key
2. Match target status name (e.g. "To Do", "Done", "Backlog") against available transitions
3. Use the matched transition ID
4. If no match: log warning, skip card, continue with next

Show summary:
```
Done: 3 To Do | 2 Backlog | 1 Waiting | 1 Closed
```

## Rules

- Max 2 lines per card (title line + why-waiting line)
- Plain text only, NO markdown tables — must be mouse-selectable
- Extract blocker reason from description (product decision? credential? dependency?)
- Wait for single-line user reply before acting
- On transition failure -> auto-retry with correct transition ID via `getTransitionsForJiraIssue`
