---
name: jira-run-fast
description: "Jira fast loop — fixed 1-second interval, configurable round count (e.g. 100 = 100 rounds x 1s). Cancel with /jira-cancel."
allowed-tools: ["Bash", "Read", "Write", "Edit", "Grep", "Glob", "mcp__atlassian__*"]
argument-hint: "[rounds] — e.g. 100 | empty = 10 rounds x 1s"
---

## What it does

**Fixed:** interval is always **`1s`** (1 second).

**Variable:** round count `N` — user-provided or **default `N = 10`**.

**Equivalent:** **`/jira-run <N> 1s`** (e.g. `100` = `/jira-run 100 1s`).

Full Jira loop, summary blocks, cancellation and protocol: see `/jira-run` command. This command only sets **1s fixed + round count resolution**; all `/jira-run` rules apply (**Claude Code:** background, **Cursor:** current chat).

## Argument resolution

| Input | `N` (round count) |
|-------|--------------------|
| Empty, just `/jira-run-fast` | **10** |
| Single number token (e.g. `100`, `50`, `1`) | `max(1, parseInt(token))` — minimum **1** round |
| First token is number, extras present (e.g. `100 foo`) | `N` = first token; extra tokens ignored with note |
| First token is not a number | Warning + **N = 10** |

After resolving `N`, execute as `/jira-run <N> 1s`.

## Startup (mandatory — run before anything else)

```bash
rm -f .jira-state/jira-run.stop
```

## Execution

1. **Equivalent call:** Apply `/jira-run` with `<N> 1s` argument (e.g. `/jira-run 100 1s`).
2. **Environment:** See `/jira-run` execution mode — **Claude Code** full loop **only in background**; **Cursor** full loop in **current chat**.

## Cancel

**`/jira-cancel`** — see jira-cancel command.

## Rules

- Bulk sleep + single/double JQL to fake `N` rounds is **invalid**.
- **Claude Code** foreground "run here" is **not allowed** — background required. **Cursor** has no such constraint.
- **Rounds never empty:** Every round must have at least one Jira write (transition, create, edit, or protocol scope).
