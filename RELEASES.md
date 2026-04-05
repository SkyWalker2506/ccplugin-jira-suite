# Releases

## v1.1.0 — 2026-04-05
### Security & Critical Fixes (Sprint 1)
- Replace curl basic auth with header-based authentication
- Add input validation for PROJECT_KEY and ISSUE_KEY (regex)
- Pin mcp-remote to fixed version (remove @latest)
- Add chmod 600 to setup-token flow for secrets.env
- Create .gitignore for cache and state files
- Fix column name JSON injection with proper escaping
- Add dependency checks (python3, curl) at startup
- Fix silent HTTP error pass in create-project
- Create missing scripts (dashboard.py, run_task_agent.sh)

## v1.0.0 — 2026-04-01
### Initial Release
- Jira run loop with configurable rounds and interval
- Fast loop mode (1-second intervals)
- Detailed board audit command
- Cancel running loops
- Multi-agent task pipeline (Sonnet code + Opus review)
- WAITING card decision loop
- Terminal dashboard (cached + live sync)
- Column templates system (8 templates)
- Sprint planning integration
