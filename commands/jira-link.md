---
name: jira-link
description: "Create issue links between Jira cards — blocks, is-blocked-by, relates-to, duplicates."
allowed-tools: ["Bash", "Read", "mcp__atlassian__createIssueLink", "mcp__atlassian__getIssueLinkTypes", "mcp__atlassian__getJiraIssue"]
argument-hint: "<FROM_KEY> <type> <TO_KEY> — e.g. JS-10 blocks JS-15"
---

## What it does

Create a link between two Jira issues.

## Arguments

| Input | Behavior |
|-------|----------|
| `JS-10 blocks JS-15` | JS-10 blocks JS-15 |
| `JS-10 relates JS-15` | JS-10 relates to JS-15 |
| `JS-10 duplicates JS-15` | JS-10 duplicates JS-15 |
| `JS-10 blocked-by JS-15` | JS-10 is blocked by JS-15 |

## Execution

### 1. Parse arguments
Extract FROM_KEY, link type, TO_KEY from arguments.

### 2. Resolve link type
Call `getIssueLinkTypes` to get available link types.
Match user input (case-insensitive, partial match):
- `blocks` / `block` → "Blocks" (outward: "blocks", inward: "is blocked by")
- `blocked-by` / `blocked` → "Blocks" (reversed direction)
- `relates` / `related` → "Relates" 
- `duplicates` / `duplicate` / `dupe` → "Duplicate"
- `clones` / `clone` → "Cloners"

### 3. Create link
Call `createIssueLink` with:
```json
{
  "type": {"name": "<resolved_type>"},
  "inwardIssue": {"key": "<inward_key>"},
  "outwardIssue": {"key": "<outward_key>"}
}
```

### 4. Confirm
```
✓ JS-10 blocks JS-15
```

If error, show the error and available link types.
