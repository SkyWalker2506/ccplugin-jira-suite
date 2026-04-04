---
name: jira-cancel
description: "Stop the jira-run loop by writing a stop file. If main agent is busy, use terminal fallback."
allowed-tools: ["Bash"]
argument-hint: "no arguments"
---

## What it does

Stops a running `/jira-run` loop by creating the stop file `.jira-state/jira-run.stop`.

## Claude Code constraint

The main session processes commands **sequentially**. If the main agent is producing output, `/jira-cancel` **queues** — this is product behavior and cannot be fully bypassed with `run_in_background`.

**Immediate cancel (without waiting for main agent):** Open a separate terminal at repo root:

```bash
mkdir -p .jira-state && touch .jira-state/jira-run.stop
```

## Execution

On trigger, run at repo root:

```bash
mkdir -p .jira-state && touch .jira-state/jira-run.stop
```

Then inform the user:

- `/jira-run` will exit at the **start of the next round**.
- If the main session is still busy and this command was delayed, remind: open a terminal and run `mkdir -p .jira-state && touch .jira-state/jira-run.stop`

## Working lock note

This command cancels `/jira-run`, **not** individual task implementation agents. To clear a working lock left by a crashed implementation agent:

```bash
rm -f .jira-state/working-{KEY}-XX.lock
# or clear all:
rm -f .jira-state/working-*.lock
```

See `docs/CLAUDE_JIRA.md` (Lock System) for details.
