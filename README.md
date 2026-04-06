# jira-suite — Claude Code Plugin

by [Musab Kara](https://linkedin.com/in/musab-kara-85580612a) · [GitHub](https://github.com/SkyWalker2506)

Jira and sprint management suite for Claude Code — run loops, dashboards, decisions, task pipelines.

## Install

```bash
claude plugin install jira-suite@musabkara-claude-marketplace
```

## Getting Started

New to jira-suite? → **[docs/GETTING_STARTED.md](docs/GETTING_STARTED.md)** — zero to dashboard in 5 minutes, with or without a Jira account.

## Quickstart

1. Install the plugin: `claude plugin install jira-suite@musabkara-claude-marketplace`
2. Create `docs/CLAUDE_JIRA.md` in your project with your Jira project key and cloudId
3. Run `/dashboard-sync` to verify Jira connection
4. Use `/jira-run` to start the automated check loop
5. Use `/decide` to review and action WAITING cards

## Why jira-suite?

- **Autonomous loops** — `/jira-run` continuously checks your board, transitions cards, and reports status without manual intervention
- **Decision pipeline** — `/decide` surfaces WAITING cards for quick T(op)/B(ottom)/W(ait)/D(one) decisions
- **Multi-agent task runner** — `/jira-start-new-task` picks unassigned tasks and runs a Sonnet code + Opus review pipeline per task
- **Zero-token dashboard** — `/dashboard` renders your board from cache, no API calls needed
- **Drop-in plugin** — one install command, works with any Jira project via `docs/CLAUDE_JIRA.md` config

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
| `/jira-admin` | Admin operations: bulk transitions, cleanup, board maintenance |
| `/jira-init` | Initialize `docs/CLAUDE_JIRA.md` config for a new project |
| `/jira-link` | Link a Jira issue to a GitHub PR or commit |
| `/jira-report` | Generate a sprint or project status report |
| `/jira-switch` | Switch active Jira project context |
| `/jira-worklog` | Log time spent on a Jira issue |

## Setup

1. Install the plugin in Claude Code
2. Ensure Atlassian MCP server is configured (included in `.mcp.json`)
3. Each project needs a `docs/CLAUDE_JIRA.md` with project key, cloudId, and JQL queries

## MCP Dependency

This plugin requires the Atlassian MCP server for Jira API access. The configuration is included in `.mcp.json`.

## License

MIT

## Part of

- [claude-config](https://github.com/SkyWalker2506/claude-config) — Multi-Agent OS for Claude Code (134 agents, local-first routing)
- [Plugin Marketplace](https://github.com/SkyWalker2506/claude-marketplace) — Browse & install all 18 plugins
- [ClaudeHQ](https://github.com/SkyWalker2506/ClaudeHQ) — Claude ecosystem HQ
