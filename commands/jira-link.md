---
name: jira-link
description: "Create issue links between Jira cards — blocks, relates-to, duplicates. Also links GitHub PR URLs to Jira issues."
allowed-tools: ["Bash", "Read", "mcp__atlassian__createIssueLink", "mcp__atlassian__getIssueLinkTypes", "mcp__atlassian__getJiraIssue", "mcp__atlassian__fetch"]
argument-hint: "<FROM_KEY> <type> <TO_KEY|PR_URL> — e.g. JS-10 blocks JS-15 | JS-10 pr https://github.com/.../pull/42"
---

## What it does

Create a link between two Jira issues, or link a GitHub PR URL to a Jira issue as a remote web link.

## Arguments

| Input | Behavior |
|-------|----------|
| `JS-10 blocks JS-15` | JS-10 blocks JS-15 |
| `JS-10 relates JS-15` | JS-10 relates to JS-15 |
| `JS-10 duplicates JS-15` | JS-10 duplicates JS-15 |
| `JS-10 blocked-by JS-15` | JS-10 is blocked by JS-15 |
| `JS-10 pr https://github.com/owner/repo/pull/42` | Links PR #42 to JS-10 as a web link |
| `JS-10 https://github.com/.../pull/42` | Same — `pr` keyword is optional when URL is a GitHub PR |

## Execution

### 1. Parse arguments

Extract FROM_KEY and second token(s).

**GitHub PR detection:** If the second token is `pr` or the third token starts with `https://github.com/` and contains `/pull/`, treat as PR link mode (see Step 2b).

Otherwise, extract FROM_KEY, link type, TO_KEY as usual.

### 2a. Issue-to-issue link (standard mode)
Call `getIssueLinkTypes` to get available link types.
Match user input (case-insensitive, partial match):
- `blocks` / `block` → "Blocks" (outward: "blocks", inward: "is blocked by")
- `blocked-by` / `blocked` → "Blocks" (reversed direction)
- `relates` / `related` → "Relates" 
- `duplicates` / `duplicate` / `dupe` → "Duplicate"
- `clones` / `clone` → "Cloners"

Call `createIssueLink` with:
```json
{
  "type": {"name": "<resolved_type>"},
  "inwardIssue": {"key": "<inward_key>"},
  "outwardIssue": {"key": "<outward_key>"}
}
```

### 2b. GitHub PR link mode (new)

When a GitHub PR URL is provided:

1. **Parse PR URL** — extract owner, repo, PR number from URL:
   - Pattern: `https://github.com/{owner}/{repo}/pull/{number}`
   - Validate format — must match this pattern
2. **Derive PR title** — use format `PR #{number}: {owner}/{repo}`
   - Optionally fetch PR title via GitHub API if `gh` CLI available: `gh pr view {number} --repo {owner}/{repo} --json title --jq .title`
3. **Create remote web link on Jira issue** using Atlassian MCP `fetch` POST to:
   `POST /rest/api/3/issue/{FROM_KEY}/remotelink`
   Body:
   ```json
   {
     "object": {
       "url": "<PR_URL>",
       "title": "<PR_TITLE>",
       "icon": {
         "url16x16": "https://github.com/favicon.ico",
         "title": "GitHub"
       }
     },
     "application": {
       "type": "com.github",
       "name": "GitHub"
     },
     "relationship": "GitHub Pull Request"
   }
   ```
4. **Confirm**:
   ```
   ✓ JS-10 → linked to GitHub PR #42 (owner/repo)
   ```

### 3. Error handling
If error, show the error and available link types.

## Bulk Mode

Link multiple issues at once:

| Input | Behavior |
|-------|----------|
| `JS-10,JS-11,JS-12 blocks JS-20` | All three block JS-20 |
| `JS-10 relates JS-11,JS-12,JS-13` | JS-10 relates to all three |
| `bulk` | Interactive mode — paste issue keys |

### Bulk Argument Parsing
- Comma-separated keys on either side expand to multiple links
- Each expanded pair is processed independently
- Show progress: `[1/3] JS-10 blocks JS-20 ✓`

### Interactive Bulk Mode
When argument is `bulk`:
```
Bulk link mode. Enter links one per line (empty line to finish):
Format: FROM_KEY type TO_KEY

> JS-10 blocks JS-20
> JS-11 relates JS-12
> JS-13 duplicates JS-14
>

✓ 3 links created (0 errors)
```
