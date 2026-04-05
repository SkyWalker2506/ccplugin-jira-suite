# Use Cases — jira-suite

## 1. Solo Developer Sprint Management

**Scenario:** You're a solo developer managing a Jira project. You want to automate board maintenance while you code.

**Setup:**
```bash
claude plugin install jira-suite@musabkara-claude-marketplace
# In your project directory:
/jira-init MY_PROJECT
/dashboard-sync
```

**Daily Workflow:**
1. Start your session: `/dashboard` — see board status at a glance
2. Pick a task: `/jira-start-new-task` — auto-selects highest priority To Do, creates branch, codes, PRs
3. While coding, run `/jira-run 50 1s` in background — keeps board clean, moves stale cards
4. End of day: `/jira-report` — see what got done

**Key Commands:** `/dashboard`, `/jira-start-new-task`, `/jira-run`, `/jira-report`

---

## 2. Multi-Agent Task Pipeline

**Scenario:** You have 5+ tasks in To Do and want to parallelize implementation with automated code review.

**Setup:**
```bash
/jira-init PROJECT_KEY
/dashboard-sync
```

**Workflow:**
1. Queue tasks in Jira (To Do status, with descriptions)
2. Run `/jira-start-new-task 5` — picks 5 tasks, starts parallel pipelines
3. Each task: Sonnet codes → creates PR → Opus reviews → merges → Done
4. Monitor with `/dashboard` (cached, zero-token)
5. If a task blocks: `/decide` to review WAITING cards

**What happens automatically:**
- Branch creation per task
- File-level locking prevents edit conflicts
- Code review with quality checks
- Squash merge + branch cleanup
- Jira status transitions

---

## 3. Team Board Maintenance & Audit

**Scenario:** You're a tech lead who wants to keep the Jira board clean and well-organized.

**Setup:**
```bash
/jira-init TEAM_PROJECT
```

**Weekly Workflow:**
1. Monday: `/jira-run-detailed` — deep audit finds stale cards, missing descriptions, wrong priorities
2. Review suggestions, approve fixes
3. `/decide` — clear out WAITING cards with quick T/B/W/D decisions
4. `/jira-report full` — share sprint health with team
5. `/jira-link JS-10 blocks JS-15` — document dependencies

**Audit focuses:** Run `/jira-run-detailed security` before releases, `/jira-run-detailed tech-debt` monthly.
