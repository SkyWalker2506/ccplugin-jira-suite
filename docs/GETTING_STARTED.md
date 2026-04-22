# Getting Started — Zero to Dashboard in 5 Minutes

Two paths: **Track A** (no Jira account needed) or **Track B** (real Jira project).

---

## Track A: Demo — No Jira Account Required

Test every command with pre-built sample data in under 2 minutes.

**Step 1 — Install the plugin**
```bash
claude plugin install jira-suite@musabkara-claude-marketplace
```

**Step 2 — Load demo data**
```bash
cp .demo/CLAUDE_JIRA.demo.md docs/CLAUDE_JIRA.md
cp .demo/sample_cache.json .jira_cache.json
```

**Step 3 — Open your dashboard**
```
/dashboard
```

That's it. The dashboard renders from cache — zero API calls, zero tokens. Browse your sample board, try `/decide` to action WAITING cards, and explore the plugin before connecting real Jira.

---

## Track B: Real Jira — Full Setup

**Step 1 — Install the plugin**
```bash
claude plugin install jira-suite@musabkara-claude-marketplace
```

**Step 2 — Get your MCP token**

Open Claude Code settings → MCP Servers → Atlassian. Add your Atlassian API token:
- Generate token at: https://id.atlassian.com/manage-profile/security/api-tokens
- The `.mcp.json` bundled with this plugin pre-configures the Atlassian MCP server — you only need to supply the token.

**Step 3 — Initialize your project config**
```
/jira-init
```

This creates `docs/CLAUDE_JIRA.md` in your project. When prompted, provide:
- Your Jira project key (e.g. `JS`, `TASK`)
- Your Cloud ID (find it at `https://your-domain.atlassian.net/_edge/tenant_info`)
- Your Board ID (from the board URL: `.../boards/NNN`)

**Step 4 — Sync and verify**
```
/dashboard-sync
```

Fetches live data from Jira, writes the local cache, and renders your board. If this succeeds, you're fully connected.

**Step 5 — Start working**
```
/decide
```

Review WAITING FOR APPROVAL cards. Press `T` (top priority), `B` (bottom), `W` (keep waiting), or `D` (done). The plugin transitions Jira automatically.

---

## What's Next

| Command | What it does |
|---------|--------------|
| `/jira-run` | Continuous loop — checks board, transitions cards, reports status |
| `/jira-start-new-task` | Pick unassigned tasks, run Sonnet code + Opus review pipeline |
| `/dashboard` | Instant board view from cache (no API calls) |
| `/jira-report` | Generate sprint or project status report |
| `/jira-admin` | Bulk transitions, cleanup, board maintenance |

---

## Using jira-suite in IDEs

### VS Code (with Claude extension)

If you use the [Claude for VS Code extension](https://marketplace.visualstudio.com/items?itemName=Anthropic.claude):

1. Install jira-suite from the Claude extension marketplace panel
2. Open your project folder in VS Code
3. Use commands in the Claude chat panel exactly as you would in Claude Code CLI:
   ```
   /dashboard-sync
   /jira-run 10 1m
   /decide
   ```
4. The extension shares the same plugin config — your `docs/CLAUDE_JIRA.md` is read from the open workspace root

**Note:** Background agents (`jira-run` in background mode) require Claude Code CLI. In VS Code, the loop runs in the active chat session.

### Cursor

Cursor supports Claude Code plugins natively:

1. Open Cursor settings → AI → Claude Plugins
2. Install `jira-suite` or point to the local plugin directory
3. Open your project in Cursor
4. Use commands in any chat window:
   ```
   /dashboard
   /jira-start-new-task 3
   /jira-report full
   ```

**Cursor advantage:** Cursor's inline editing mode pairs well with `/jira-start-new-task` — the task agent writes code directly into your editor while Jira transitions are handled in the background.

### Tip: multi-project in IDEs

If you work across multiple Jira projects in one IDE session, use `/jira-switch`:
```
/jira-switch JS      ← switch to JS project
/jira-switch VOC     ← switch to VOC project
/jira-switch         ← list available projects
```

---

## Troubleshooting

### "MCP server not connected" or Atlassian tool errors
The Atlassian MCP server is not running or not authenticated. Check:
1. Your API token is set in MCP settings (Claude Code → Settings → MCP Servers)
2. Restart Claude Code after adding the token
3. Run `/dashboard-sync` again — it will report a clear auth error if the token is wrong

### `/dashboard` shows blank or stale data
The local cache (`.jira_cache.json`) is missing or outdated. Fix:
```
/dashboard-sync
```
This always fetches fresh data from Jira and rebuilds the cache.

### `/jira-init` can't find my project or board
Your Cloud ID or Board ID is wrong. Verify:
- Cloud ID: visit `https://your-domain.atlassian.net/_edge/tenant_info` and copy `cloudId`
- Board ID: open your Jira board in the browser; the URL ends with `/boards/NNN` — use that number
- Then re-run `/jira-init` or edit `docs/CLAUDE_JIRA.md` directly
