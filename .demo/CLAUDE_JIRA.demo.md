# Jira Configuration — Demo Project

## Project
- **Key:** DEMO
- **Cloud ID:** demo-cloud-id-12345
- **Board ID:** 999

## JQL Queries
```
project = DEMO AND status NOT IN ("Done") ORDER BY status ASC, priority DESC
project = DEMO AND status = "Done" ORDER BY updated DESC
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
