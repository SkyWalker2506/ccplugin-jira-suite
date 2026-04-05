# Demo Sandbox — jira-suite

This directory contains sample data for testing jira-suite commands without a real Jira connection.

## Quick Start

1. Copy the sample config:
```bash
cp .demo/CLAUDE_JIRA.demo.md docs/CLAUDE_JIRA.md
```

2. Load sample cache:
```bash
cp .demo/sample_cache.json .jira_cache.json
```

3. Test the dashboard:
```bash
/dashboard
```

## Files

| File | Purpose |
|------|---------|
| `CLAUDE_JIRA.demo.md` | Sample Jira config (fake project DEMO-*) |
| `sample_cache.json` | Pre-built cache with sample issues |
| `README.md` | This file |

## Note

Demo data uses project key `DEMO`. No actual Jira API calls are made when using cached data with `/dashboard`.
