# Lock System — Multi-Agent File Safety

## Purpose

When `/jira-start-new-task` runs multiple agents in parallel, file locks prevent conflicting edits.

## Lock Directory

`.jira-state/file-locks/` — one file per locked resource.

## Lock Format

```json
{
  "file": "src/components/Header.tsx",
  "owner": "JS-42",
  "agent": "B2-coder",
  "acquired": "2026-04-05T10:30:00Z",
  "ttl": 600
}
```

## Rules

1. **Acquire before edit** — check `.jira-state/file-locks/{hash}.lock` before modifying any file
2. **TTL expiry** — locks older than TTL (default 600s) are considered stale and can be overridden
3. **Release on complete** — agent removes its locks after commit + push
4. **Working lock** — `.jira-state/working-{ISSUE_KEY}.lock` marks the task as actively being worked on

## Commands

| Action | How |
|--------|-----|
| Check lock | `cat .jira-state/file-locks/{hash}.lock` |
| List active | `ls .jira-state/file-locks/` |
| Force release | `rm .jira-state/file-locks/{hash}.lock` (manual only) |
| Check working | `ls .jira-state/working-*.lock` |
