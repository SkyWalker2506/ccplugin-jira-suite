# Jira Configuration — DEMO Project

> This is a **demo/sandbox** configuration. It uses mock data and does not connect to a real Jira instance.
> Use this to test jira-suite commands without affecting your actual project.

## Project
- **Key:** DEMO
- **Cloud ID:** demo-cloud-id
- **Board ID:** 1

## JQL Queries
```
# Active work
project = DEMO AND status NOT IN ("Done") ORDER BY status ASC, priority DESC

# Recently done
project = DEMO AND status = "Done" ORDER BY updated DESC
```

## Status Mapping
| Jira Status | Plugin Status |
|-------------|---------------|
| To Do | todo |
| In Progress | in_progress |
| WAITING FOR APPROVAL | waiting |
| BLOCKED | blocked |
| Done | done |

## Transition IDs
| Transition | ID |
|------------|----|
| To Do → In Progress | 21 |
| → WAITING FOR APPROVAL | 71 |
| → Done | 31 |

## Labels
- `demo`, `test`

## Sprint
- **Active Sprint:** Sprint 1 (demo)
- **Sprint Duration:** 2 weeks

## Notes
- This config is for first-time testing only.
- Copy this file to `docs/CLAUDE_JIRA.md` and update with your real project details.
- See `docs/GETTING_STARTED.md` for setup instructions.
