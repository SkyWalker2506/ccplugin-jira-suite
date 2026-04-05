# Jira Configuration — <PROJECT_NAME>

## Project
- **Key:** <PROJECT_KEY> (e.g., JS, VOC, TASK)
- **Cloud ID:** <CLOUD_ID> (find at: https://your-domain.atlassian.net/_edge/tenant_info)
- **Board ID:** <BOARD_ID> (from board URL: /jira/software/projects/XX/boards/NNN)

## JQL Queries
```
# Active work
project = <PROJECT_KEY> AND status NOT IN ("Done") ORDER BY status ASC, priority DESC

# Recently done
project = <PROJECT_KEY> AND status = "Done" ORDER BY updated DESC
```

## Status Mapping
| Jira Status | Plugin Status |
|-------------|---------------|
| To Do | todo |
| In Progress | in_progress |
| WAITING FOR APPROVAL | waiting |
| BLOCKED | blocked |
| BACKLOG | backlog |
| Done | done |

## Transition IDs
> Transition IDs vary per project and workflow. Always use dynamic lookup:
> `getTransitionsForJiraIssue` returns available transitions for each issue.
>
> Common transitions (for reference only — always verify dynamically):

| Transition | Typical ID |
|------------|------------|
| To Do → In Progress | 21 |
| → WAITING FOR APPROVAL | 7 |
| → Done | 31 |

## Labels
- `security`, `arch`, `growth`, `competitive`

## Sprint
- **Active Sprint:** auto-detected via JQL
- **Sprint Duration:** 2 weeks
