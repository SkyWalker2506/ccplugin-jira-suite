---
name: dashboard
description: "Terminal dashboard — reads from cache, zero tokens. Use /dashboard-sync for fresh data."
allowed-tools: ["Bash"]
argument-hint: "no arguments"
---

## What it does

Reads from `.jira_cache.json` and renders a terminal dashboard. Zero Jira API calls, zero tokens.

## Execution

```bash
python3 scripts/dashboard.py
```

After output, do NOT add extra commentary.

If cache does not exist, warn: "No cache found. Run `/dashboard-sync` first."
