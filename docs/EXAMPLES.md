# Command Examples — jira-suite

## /dashboard

```
============================================================
  JIRA DASHBOARD
  Updated: 2026-04-05T14:30:00Z
============================================================

  Total: 15  |  To Do: 4  |  IP: 3  |  Waiting: 2  |  Blocked: 1  |  Backlog: 3  |  Done: 8

  --- IN PROGRESS (3) ---
  JS-42  Fix authentication flow                        High    #security
  JS-40  Add retry logic to API calls                   Medium  #arch
  JS-38  Update README quickstart                       Low     #growth

  --- BLOCKED (1) ---
  JS-35  Deploy to staging                              High    #arch

  --- WAITING (2) ---
  JS-33  Add payment integration                        High    #competitive
  JS-31  Change color scheme                            Low     #growth

  --- TO DO (4) ---
  JS-30  Sprint auto-detection                          Medium  #competitive
  JS-29  Issue linking support                          Medium  #competitive
  JS-28  Token rotation reminder                        Low     #security
  JS-27  Add audit log                                  Low     #arch

  --- DONE (recent 3) ---
  JS-25  Create .gitignore
  JS-24  Pin mcp-remote version
  JS-23  Add input validation

============================================================
```

## /decide

```
 1  JS-33  Add payment integration                      High  #competitive
    Why waiting: Needs Stripe API key from admin

 2  JS-31  Change color scheme                          Low   #growth
    Why waiting: Waiting for design approval

T = To Do    B = Backlog    W = Keep waiting    D = Close

Reply examples:
  1T 2B
  all T
```

## /jira-run

```
[JiraRun] Started — Rounds: 10, Interval: 60s, Cancel: /jira-cancel

[Round 1/10]
  ✓ JS-42: In Progress — lock active
  ✓ JS-35: BLOCKED — dependency on JS-42
  ⚠ JS-40: Stale IP (no lock, 2h) → moved to To Do
  Summary: 15 active | 1 transitioned | 0 errors

[Round 2/10]
  ✓ No changes detected
  Summary: 15 active | 0 transitioned | 0 errors

[JiraRun] Done — 10 rounds completed (no cancel).
```

## /jira-start-new-task 2

```
2 tasks started:
  [To Do → IP] JS-30 — Sprint auto-detection (pipeline started)
  [To Do → IP] JS-29 — Issue linking support (pipeline started)

Pipeline: Sonnet code → PR → Opus review → merge → Done
```

## /jira-report

```
SPRINT REPORT — JS
Generated: 2026-04-05T14:30:00Z

Status Breakdown:
  In Progress:  ██████░░░░  3
  To Do:        ████░░░░░░  2
  Waiting:      ██░░░░░░░░  1
  Blocked:      ██░░░░░░░░  1
  Done (recent): ████████░░  8

Total Active: 7 | Done (last 7d): 8
Health: 🟡 Attention needed (1 blocked)
```

## /jira-link

```
✓ JS-10 blocks JS-15
```

## /jira-worklog

```
✓ JS-42: logged 2h (7200s)
  Total logged: 5h 30m
```
