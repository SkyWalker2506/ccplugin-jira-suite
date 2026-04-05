---
name: jira-start-new-task
description: "Pick N tasks from orphan IP or To Do, start Sonnet code + Opus review pipeline per task (branch -> PR -> review -> merge)."
allowed-tools: ["Bash", "Read", "Write", "Edit", "Grep", "Glob", "mcp__atlassian__*"]
argument-hint: "[N=1] — number of tasks to start (max 20)"
---

## What it does

1. **Argument resolution:** No number = N=1; otherwise that number (min 1, max 20)
2. **Priority 1 — Orphan IP cards:** In Progress cards with no working lock or stale lock (>15min)
3. **Priority 2 — To Do:** Fill remaining N from To Do by priority DESC, transition to IP
4. **Nothing found:** "Could not find N tasks — no orphan IP or To Do cards available."
5. **Per card:** Start 2-step pipeline via `scripts/run_task_agent.sh`

## 2-Step Pipeline (per task)

### Step 1 — Code (Sonnet)
- Create `feat/{key}-xxx` branch (from main)
- Write code, respect file lock rules
- Run build/analyze/test
- `git commit` + `git push -u origin feat/{key}-xxx`
- `gh pr create --base main`
- **Does NOT merge** — waits for review

### Step 2 — Review (Opus)
- Find PR (`gh pr list --head feat/{key}-xxx`)
- `git checkout feat/{key}-xxx && git pull`
- `git diff main...feat/{key}-xxx` — review all changes
- Run analyze + test
- Code quality check (imports, types, patterns, null safety, test coverage)
- Issues found: fix, commit, push, re-analyze+test
- Clean: `gh pr merge --squash --delete-branch`
- `git checkout main && git pull`
- Jira Done transition (via dynamic getTransitionsForJiraIssue lookup)

**Model rule:** Code = min Sonnet, Review = Opus. Haiku never writes code.

## Argument resolution

| Input | N |
|-------|---|
| `/jira-start-new-task` | **1** |
| `/jira-start-new-task 5` | **5** |
| `/jira-start-new-task 100` | **20** (max cap) |
| `/jira-start-new-task foo` | Warning + **1** |
| Multiple args | First token, rest ignored |

## File lock system (collision prevention)

Multiple sub-agents working in the same repo use **file-level locks** in `.jira-state/file-locks/`.

Lock format: `.jira-state/file-locks/<encoded-path>.lock` containing `<KEY> <TIMESTAMP>`

Encoded path: `/` replaced with `__` (e.g. `lib__domain__entities__word.dart.lock`)

### Lock rules for sub-agents
1. Before editing a file, **acquire lock**: `echo "<KEY> $(date +%s)" > .jira-state/file-locks/<encoded>.lock`
2. After editing, **release lock**: `rm -f .jira-state/file-locks/<encoded>.lock`
3. Before editing, **check lock**: no lock = acquire; lock by other KEY = skip/wait; own KEY = proceed
4. New files also require locks
5. On process exit, clean all own locks: `rm -f .jira-state/file-locks/*<KEY>* 2>/dev/null`

## Execution sequence

### Step 0 — Create lock directory
```bash
mkdir -p .jira-state/file-locks
```

### Step 1 — Find orphan IP cards
JQL: `project = {KEY} AND status = "In Progress" ORDER BY priority DESC`
- No lock -> orphan, add to list
- Stale lock (>15min) -> delete stale + file locks, add to list
- Fresh lock (<15min) -> active agent, skip

### Step 2 — Fill remaining N from To Do
JQL: `project = {KEY} AND status = "To Do" ORDER BY priority DESC`
Per card: Call getTransitionsForJiraIssue, find "In Progress" transition, apply it, write lock, start sub-agent.

### Step 3 — If empty, report
```
Could not find N tasks — no orphan IP or To Do cards available.
```

## Output

### Success
```
N tasks started:
  [IP orphan] {KEY}-123 — Task Title (lock renewed)
  [To Do -> IP] {KEY}-125 — New Task

Pipeline: Sonnet code -> PR -> Opus review -> merge -> Done
Logs: /tmp/impl-{KEY}-XXX.log, /tmp/review-{KEY}-XXX.log
```

### Nothing found
```
Could not find N tasks — no orphan IP or To Do cards available.
```

## Technical notes

- **Working lock:** `.jira-state/working-<KEY>.lock` — task level (Jira status)
- **File lock:** `.jira-state/file-locks/<path>.lock` — file level (collision prevention)
- **Stale threshold:** 15 minutes (900000 ms)
- **Cleanup:** `trap cleanup EXIT INT TERM` — auto-cleanup on kill/crash
- **Max N:** 20 (too many parallel agents cause memory/CPU issues)
- **Branch pattern:** `feat/{key}-xxx` (key lowercase)
- **PR merge:** `--squash --delete-branch` (clean git history)
