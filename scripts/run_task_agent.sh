#!/usr/bin/env bash
# run_task_agent.sh — Start implementation + review pipeline for a single Jira task.
# Usage: ./scripts/run_task_agent.sh <ISSUE_KEY> <PROJECT_KEY>
#
# This script is called by /jira-start-new-task for each task.
# Step 1: Sonnet codes (branch + PR)
# Step 2: Opus reviews (review + merge + Done transition)

set -euo pipefail

ISSUE_KEY="${1:?Usage: run_task_agent.sh <ISSUE_KEY> <PROJECT_KEY>}"
PROJECT_KEY="${2:?Usage: run_task_agent.sh <ISSUE_KEY> <PROJECT_KEY>}"

# Validate inputs
[[ "$ISSUE_KEY" =~ ^[A-Z][A-Z0-9]{1,9}-[0-9]+$ ]] || { echo "Invalid ISSUE_KEY: $ISSUE_KEY"; exit 1; }
[[ "$PROJECT_KEY" =~ ^[A-Z][A-Z0-9]{1,9}$ ]] || { echo "Invalid PROJECT_KEY: $PROJECT_KEY"; exit 1; }

BRANCH="feat/$(echo "$ISSUE_KEY" | tr '[:upper:]' '[:lower:]')"
LOCK_DIR=".jira-state/file-locks"
WORKING_LOCK=".jira-state/working-${ISSUE_KEY}.lock"

mkdir -p "$LOCK_DIR"

cleanup() {
    rm -f "$WORKING_LOCK"
    rm -f "$LOCK_DIR"/*"${ISSUE_KEY}"* 2>/dev/null
    rm -f "/tmp/jira_run_status.json"
    echo "[${ISSUE_KEY}] Locks cleaned up."
}
trap cleanup EXIT INT TERM

# Write working lock
echo "${ISSUE_KEY} $(date +%s)" > "$WORKING_LOCK"

echo "[${ISSUE_KEY}] Pipeline started — branch: $BRANCH"
echo "[${ISSUE_KEY}] Step 1: Code (Sonnet) — create branch, implement, PR"
echo "[${ISSUE_KEY}] Step 2: Review (Opus) — review, fix, merge, Done"
echo ""
echo "Note: This script is a launcher stub. The actual implementation"
echo "and review steps are executed by Claude Code agents following"
echo "the pipeline defined in /jira-start-new-task."
