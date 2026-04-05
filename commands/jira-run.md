---
name: jira-run
description: "Jira wait-and-check loop. Reads project key from docs/CLAUDE_JIRA.md. Configurable rounds and interval (e.g. 50 1s). Cancel with /jira-cancel."
allowed-tools: ["Bash", "Read", "Write", "Edit", "Grep", "Glob", "mcp__atlassian__*"]
argument-hint: "[rounds] [interval] — e.g. 50 1s | 10 | 10_1m | empty = 10 rounds 1min"
---

## Trigger

`/jira-run`, `/JIRA-RUN`, `JiraRun 50 1s` — all trigger this command.

## Execution mode

| Environment | Rule |
|-------------|------|
| **Claude Code** | Main session: (1) `rm -f .jira-state/jira-run.stop` (2) If IP task exists -> Implementation agent `Agent(run_in_background=true)` (3) jira-run agent `Agent(run_in_background=true)`. Both run in parallel. |
| **Cursor** | Full loop runs in current chat — background not required. |

**Claude Code constraint:** Sub-agents cannot call `Agent`. Implementation agent is started **only by the main session**.

## Startup (always first command)

```bash
rm -f .jira-state/jira-run.stop
# Register cleanup trap so /tmp/jira_run_status.json is removed on exit/interrupt
trap 'rm -f /tmp/jira_run_status.json' EXIT INT TERM
```

Run at repo root: `cd "$(git rev-parse --show-toplevel)"` if needed.

## Notifications

**A) On start** (Claude Code not in background, Cursor in this chat):
```
[JiraRun] Started — Rounds: <N>, Interval: <T>, Cancel: /jira-cancel
```

**B) Normal finish:**
```
[JiraRun] Done — <N> rounds completed (no cancel).
```

**C) Cancelled:**
```
[JiraRun] Cancelled (jira-cancel / stop file).
```

## Argument resolution (`$ARGUMENTS`)

| Input | Rounds | Interval |
|-------|--------|----------|
| empty | 10 | 1m |
| `10` | 10 | 1m |
| `50 1s` / `50_1s` | 50 | 1s |
| `10 1m` / `10_1m` | 10 | 60s |
| `1h30m` compound | — | 5400s |
| invalid | warning | default |

Units: `s`=seconds, `m`=minutes, `h`=hours (decimal supported: `0.5h`=1800s).

## Dry-run Mode

Append `--dry-run` or `dry` to arguments to enable dry-run mode.

| Input | Behavior |
|-------|----------|
| `/jira-run --dry-run` | 10 rounds, 1m interval, dry-run |
| `/jira-run 5 1s --dry-run` | 5 rounds, 1s, dry-run |
| `/jira-run dry` | 10 rounds, 1m, dry-run |

In dry-run mode:
- **Reads** all data normally (JQL queries, issue details)
- **Shows** what transitions/edits would be made
- **Does NOT** execute any writes (no transitions, no edits, no comments)
- Prefixes output with `[DRY-RUN]`
- Useful for testing JQL queries and understanding loop behavior

Example output:
```
[DRY-RUN] Would transition JS-10 → In Progress (id: 21)
[DRY-RUN] Would add comment to JS-15: "Stale IP — moving to To Do"
[DRY-RUN] Round 1/10 complete — 3 actions would be taken
```

## Auto-exit conditions

1. **No MCP (round 1)** -> update `docs/jira_loop_log.md` + cancel + exit
2. **2 consecutive empty rounds** -> log + cancel + exit
3. **Stop file** -> check at start of each round; if exists, delete + cancel message + exit

## Error Recovery

- API call failures: retry up to 3 times with exponential backoff (2s, 4s, 8s)
- MCP connection lost mid-loop: log error, attempt reconnect on next round
- Transition failure: call `getTransitionsForJiraIssue` to refresh available transitions, retry once
- If recovery fails after retries, log to `docs/jira_loop_log.md` and continue to next card/round

## Loop (each round sequence)

1. Check `.jira-state/jira-run.stop` -> exit if exists
2. Update `/tmp/jira_run_status.json` (watchdog)
3. (Round 1) MCP access check -> exit if unavailable
4. Execute `docs/CLAUDE_JIRA.md` protocol -> round summary

### Transition Resolution
All status transitions must use dynamic lookup via `getTransitionsForJiraIssue` — never hardcode transition IDs.

5. Update empty round counter -> exit if 2 consecutive
6. If not last round: `sleep(interval)`

**Forbidden:** Bulk sleep to fake N rounds; protocol-less "N rounds done" claims; full loop in foreground on Claude Code.

## Implementation Agent template

See `docs/agent-template.md` — use verbatim, fill `[...]` placeholders.

## Lock system

See `docs/LOCK_SYSTEM.md`

## Log

`docs/jira_loop_log.md` — newest on top. Updated on auto-exits.

Log rotation: after writing to log, run `source scripts/log-rotate.sh && rotate_log "docs/jira_loop_log.md" 500` to keep the log under 500 lines.
