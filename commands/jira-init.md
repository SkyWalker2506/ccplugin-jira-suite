---
name: jira-init
description: "Initialize Jira configuration for the current project — create docs/CLAUDE_JIRA.md from template, verify MCP connection, set file permissions."
allowed-tools: ["Bash", "Read", "Write", "mcp__atlassian__getAccessibleAtlassianResources", "mcp__atlassian__getVisibleJiraProjects", "mcp__atlassian__searchJiraIssuesUsingJql", "AskUserQuestion"]
argument-hint: "[PROJECT_KEY]"
---

## What it does

Bootstrap Jira configuration for the current project directory.

## Execution

### 1. Check prerequisites

- Verify `python3` and `curl` are available
- Check if Atlassian MCP is connected (call `getAccessibleAtlassianResources`)
- If MCP fails, show error and suggest checking `.mcp.json`

### 2. Create config from template

- If `docs/CLAUDE_JIRA.md` already exists, warn and ask before overwriting
- Copy `docs/CLAUDE_JIRA.example.md` as starting point
- If PROJECT_KEY argument provided, replace `<PROJECT_KEY>` placeholders
- If not provided, call `getVisibleJiraProjects` and let user pick

### 3. Auto-detect settings

- Fetch cloud ID from `getAccessibleAtlassianResources`
- Fetch project details from `getVisibleJiraProjects`
- Run a test JQL query to verify connectivity: `project = {KEY} AND status != Done ORDER BY updated DESC` (maxResults: 1)

### 4. Set permissions

```bash
chmod 600 docs/CLAUDE_JIRA.md
```

### 5. Confirm

Show summary:
```
✓ docs/CLAUDE_JIRA.md created
✓ Project: {KEY} — {name}
✓ Cloud ID: {id}
✓ MCP connection verified (1 issue fetched)
✓ File permissions set (600)
```

Suggest next: "Run `/dashboard-sync` to see your board."
