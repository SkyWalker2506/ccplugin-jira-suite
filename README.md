# ccplugin-jira-suite

Claude Code plugin for Jira and sprint management.

## Commands

| Command | Description |
|---------|-------------|
| `/jira-run [rounds] [interval]` | Jira wait-and-check loop with configurable rounds and interval |
| `/jira-run-fast [rounds]` | Fast loop with fixed 1-second interval |
| `/jira-run-detailed [focus]` | Deep board audit and maintenance (single pass) |
| `/jira-cancel` | Stop a running jira-run loop |
| `/jira-start-new-task [N]` | Pick N tasks from IP/To Do, run Sonnet code + Opus review pipeline |
| `/decide [max]` | Quick decision loop for WAITING FOR APPROVAL cards |
| `/dashboard` | Terminal dashboard from cache (zero tokens) |
| `/dashboard-sync` | Fetch fresh Jira data, update cache, show dashboard |

## Setup

1. Install the plugin in Claude Code
2. Ensure Atlassian MCP server is configured (included in `.mcp.json`)
3. Each project needs a `docs/CLAUDE_JIRA.md` with project key, cloudId, and JQL queries

## MCP Dependency

This plugin requires the Atlassian MCP server for Jira API access. The configuration is included in `.mcp.json`.

## License

MIT
