# Agent Template — Jira Task Implementation

## Overview

This template defines the agent pipeline for `/jira-start-new-task`. Each task goes through:

1. **Sonnet Coder** — creates branch, implements feature, opens PR
2. **Opus Reviewer** — reviews PR, requests changes or approves + merges

## Pipeline

```
Pick task → In Progress → Branch → Code → PR → Review → Merge → Done
```

## Agent Prompt Template

```
TASK: {ISSUE_KEY} — {summary}
PROJECT: {PROJECT_KEY}
BRANCH: feat/{issue-key-lowercase}

Steps:
1. Read the issue description and acceptance criteria
2. Create branch: git checkout -b {BRANCH}
3. Implement the feature/fix
4. Run tests if available
5. Commit with conventional commit message referencing {ISSUE_KEY}
6. Push and create PR
```

## Review Prompt Template

```
REVIEW: PR #{pr_number} for {ISSUE_KEY}
Check: correctness, security, style, test coverage
Action: approve + merge, or request changes with specific feedback
```

## Lock System

See [LOCK_SYSTEM.md](../docs/LOCK_SYSTEM.md) for file-level lock management during multi-agent runs.
