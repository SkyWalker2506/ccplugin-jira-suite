# Sprint Plan — ccplugin-jira-suite
> Generated: 2026-04-05 | Source: analysis/MASTER_ANALYSIS.md + 4 detail reports
> Jira Project: JS | Board: 371

---

## Sprint 1: Security & Critical Fixes (2 weeks)
**Odak:** P0 guvenlik aciklari + kirik dosya referanslari
**Kapasite:** 10 SP

| # | Task | Label | Priority | SP |
|---|------|-------|----------|----|
| 1.1 | Replace `curl -u EMAIL:TOKEN` with header-based auth | security | P0 | 1 |
| 1.2 | Create missing `scripts/dashboard.py` and `scripts/run_task_agent.sh` | arch | P0 | 2 |
| 1.3 | Add input validation for PROJECT_KEY and ISSUE_KEY (regex) | security | P0 | 1 |
| 1.4 | Pin `mcp-remote` to fixed version (remove @latest) | security | P0 | 1 |
| 1.5 | Add `chmod 600` to setup-token flow for secrets.env | security | P0 | 1 |
| 1.6 | Create `.gitignore` (.jira_cache.json, .jira-state/, tmp/) | security | P1 | 1 |
| 1.7 | Fix column name JSON injection (python json.dumps escape) | security | P1 | 1 |
| 1.8 | Add dependency check (python3, curl) at startup | security | P1 | 1 |
| 1.9 | Fix HTTP error silent pass in create-project | arch | P1 | 1 |

**Total: 10 SP**

---

## Sprint 2: Growth & Onboarding (2 weeks)
**Odak:** README, keywords, setup docs, ilk kullanim deneyimi
**Kapasite:** 12 SP

| # | Task | Label | Priority | SP |
|---|------|-------|----------|----|
| 2.1 | Add README quickstart section (5-7 lines) | growth | P1 | 1 |
| 2.2 | Expand plugin.json keywords from 8 to 20 | growth | P1 | 1 |
| 2.3 | Add value proposition to README ("Why jira-suite?") | growth | P1 | 1 |
| 2.4 | Create `docs/CLAUDE_JIRA.example.md` config template | growth | P2 | 2 |
| 2.5 | Add `jira-init` command — template + MCP ping + chmod | arch | P1 | 2 |
| 2.6 | Create missing doc references (agent-template.md, LOCK_SYSTEM.md) | arch | P2 | 1 |
| 2.7 | Add GitHub repo topics (7 tags) for SEO | growth | P2 | 1 |
| 2.8 | Add changelog/releases doc (RELEASES.md) | growth | P2 | 1 |
| 2.9 | Standardize error handling — common prereq check template | arch | P2 | 2 |

**Total: 12 SP**

---

## Sprint 3: Architecture & Robustness (2 weeks)
**Odak:** Dinamik transition, state yonetimi, hata kurtarma
**Kapasite:** 13 SP

| # | Task | Label | Priority | SP |
|---|------|-------|----------|----|
| 3.1 | Replace hardcoded transition IDs with dynamic `getTransitionsForJiraIssue` | arch | P1 | 2 |
| 3.2 | Add error recovery & retry logic (exponential backoff) | arch | P2 | 2 |
| 3.3 | Document shared state schema (.jira-state/ files) | arch | P2 | 1 |
| 3.4 | Move column templates to `templates/columns.json` | arch | P2 | 1 |
| 3.5 | Add dashboard cache version field | arch | P2 | 1 |
| 3.6 | Centralize status mapping strings | arch | P2 | 2 |
| 3.7 | Add MCP connection check to dashboard-sync | arch | P2 | 1 |
| 3.8 | Add log rotation for jira_loop_log.md (max 500 lines) | arch | P3 | 1 |
| 3.9 | Clean up /tmp/jira_run_status.json in trap | arch | P3 | 1 |
| 3.10 | Add jira-cancel support for multi-agent pipeline | arch | P2 | 1 |

**Total: 13 SP**

---

## Sprint 4: Competitive Features (2 weeks)
**Odak:** Sprint auto-detection, issue linking, time tracking
**Kapasite:** 12 SP

| # | Task | Label | Priority | SP |
|---|------|-------|----------|----|
| 4.1 | Add sprint auto-detection (active sprint query) | competitive | P2 | 2 |
| 4.2 | Add issue linking support (blocks/related-to) | competitive | P2 | 2 |
| 4.3 | Add worklog/time tracking (minimal viable: estimate + actual) | competitive | P3 | 2 |
| 4.4 | Add token rotation reminder (expire < 30 days warning) | security | P3 | 2 |
| 4.5 | Add audit log for admin operations | competitive | P2 | 1 |
| 4.6 | Add interactive command menu (`/jira` intent suggest) | competitive | P3 | 1 |
| 4.7 | Add dry-run mode for jira-run | competitive | P3 | 1 |
| 4.8 | Add colored terminal output | competitive | P3 | 1 |

**Total: 12 SP**

---

## Sprint 5: Scaling & Ecosystem (2 weeks)
**Odak:** Multi-project, entegrasyonlar, community
**Kapasite:** 14 SP

| # | Task | Label | Priority | SP |
|---|------|-------|----------|----|
| 5.1 | Add multi-project support (config rotation) | competitive | P2 | 3 |
| 5.2 | Add sprint reports (burndown, velocity, completed count) | competitive | P2 | 3 |
| 5.3 | Add bulk link/relate operations | competitive | P2 | 2 |
| 5.4 | Create use-cases documentation (3 scenarios) | growth | P2 | 2 |
| 5.5 | Add command examples with terminal output to each .md | growth | P2 | 2 |
| 5.6 | Create .demo/ sandbox for first-time testing | growth | P3 | 2 |

**Total: 14 SP**

---

## Summary

| Sprint | Odak | SP | Task Count |
|--------|------|----|------------|
| 1 | Security & Critical Fixes | 10 | 9 |
| 2 | Growth & Onboarding | 12 | 9 |
| 3 | Architecture & Robustness | 13 | 10 |
| 4 | Competitive Features | 12 | 8 |
| 5 | Scaling & Ecosystem | 14 | 6 |
| **Total** | | **61** | **42** |

**Timeline:** 10 hafta (5 x 2-haftalik sprint)
**Tahmini tamamlanma:** 2026-06-14

---

**Rapor sonu** | Sprint Plan | 2026-04-05
