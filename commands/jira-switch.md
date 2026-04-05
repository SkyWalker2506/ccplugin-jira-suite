---
name: jira-switch
description: "Switch active Jira project context — rotate between multiple project configs."
allowed-tools: ["Bash", "Read", "Write", "Glob", "mcp__atlassian__getVisibleJiraProjects"]
argument-hint: "[PROJECT_KEY] — e.g. JS, VOC, TASK | 'list' to show all"
---

## What it does

Switch the active Jira project for all jira-suite commands. Supports multiple project configs.

## Config Structure

Multi-project configs are stored as:
```
docs/
├── CLAUDE_JIRA.md          ← active config (symlink or copy)
├── CLAUDE_JIRA.JS.md       ← JS project config
├── CLAUDE_JIRA.VOC.md      ← VOC project config
└── CLAUDE_JIRA.TASK.md     ← TASK project config
```

## Arguments

| Input | Behavior |
|-------|----------|
| `/jira-switch` or `list` | List available project configs |
| `/jira-switch JS` | Switch to JS project |
| `/jira-switch VOC` | Switch to VOC project |

## Execution

### List mode
```bash
echo "Available projects:"
for f in docs/CLAUDE_JIRA.*.md; do
  key=$(echo "$f" | sed 's/.*CLAUDE_JIRA\.\(.*\)\.md/\1/')
  echo "  $key"
done
echo ""
echo "Active: $(grep -o '\*\*Key:\*\* [A-Z][A-Z0-9]*' docs/CLAUDE_JIRA.md 2>/dev/null | sed 's/\*\*Key:\*\* //' || echo 'none')"
```

### Switch mode
1. Validate PROJECT_KEY format (uppercase, 2-10 chars)
2. Check `docs/CLAUDE_JIRA.{KEY}.md` exists
3. Copy to `docs/CLAUDE_JIRA.md`: `cp docs/CLAUDE_JIRA.${KEY}.md docs/CLAUDE_JIRA.md`
4. Clear cache: `rm -f .jira_cache.json`
5. Confirm:
```
✓ Switched to {KEY}
  Cache cleared — run /dashboard-sync to refresh
```

If config doesn't exist, offer to create via `/jira-init {KEY}`.
