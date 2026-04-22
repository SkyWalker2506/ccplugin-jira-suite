## v1.6.0 — 2026-04-22
### Sprint 6: Quality, Testing & Ecosystem
- Add cache schema validation (validate_cache) to dashboard.py — exits with clear error on stale or corrupt cache
- Add scripts/bump-version.sh — semver bump, RELEASES.md prepend, optional git tag, dry-run support
- Add bash test suite (tests/run_tests.sh) with 30 tests across 4 test files
- Add test_retry.sh, test_sprint_detect.sh, test_dashboard.sh, test_jira_switch.sh
- Add jira-report --export flag — saves ANSI-stripped report to reports/ directory
- Extend jira-link with GitHub PR URL mode — creates Atlassian remotelink from PR URL
- Add IDE integration guide to GETTING_STARTED.md (VS Code, Cursor, multi-project tips)
- Add GitHub issue templates (bug report, feature request) and CONTRIBUTING.md
- Add community feedback discussion template
- Expand plugin.json keywords from 8 to 20; add repository, homepage, bugs metadata fields
- Fix dashboard.py sys.path — status_map.py now importable regardless of working directory
- Add engines field to plugin.json (claude-code >=1.0.0)


# Releases

## v1.5.0 — 2026-04-05
### Scaling & Ecosystem (Sprint 5)
- Add multi-project support with /jira-switch command
- Add sprint reports (/jira-report — summary, velocity, done, full)
- Add bulk issue linking operations
- Create use-cases documentation (3 scenarios)
- Add command examples with terminal output
- Create .demo/ sandbox for testing without Jira

## v1.4.0 — 2026-04-05
### Competitive Features (Sprint 4)
- Add sprint auto-detection with openSprints() JQL
- Add issue linking command (/jira-link — blocks/relates/duplicates)
- Add worklog/time tracking command (/jira-worklog)
- Add token rotation reminder (30-day expiry warning)
- Add audit log for admin operations
- Add interactive command menu for /jira intent
- Add dry-run mode for jira-run
- Add shared color helpers

## v1.3.0 — 2026-04-05
### Architecture & Robustness (Sprint 3)
- Replace hardcoded transition IDs with dynamic lookup
- Add error recovery with exponential backoff retry
- Document shared state schema
- Move column templates to templates/columns.json
- Add dashboard cache version field
- Centralize status mapping
- Add MCP connection check to dashboard-sync
- Add log rotation and trap cleanup
- Add jira-cancel support for multi-agent pipeline

## v1.2.0 — 2026-04-05
### Growth & Onboarding (Sprint 2)
- Add README quickstart and value proposition sections
- Expand plugin.json keywords from 8 to 20
- Create CLAUDE_JIRA.example.md config template
- Add /jira-init command for project bootstrap
- Create agent-template.md and LOCK_SYSTEM.md docs
- Add RELEASES.md changelog
- Standardize error handling with prereq-check.sh
- Add GitHub repo topics for SEO

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