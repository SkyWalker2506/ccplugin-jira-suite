#!/usr/bin/env bash
# sprint-detect.sh — Detect active sprint for a Jira project.
# Usage: source "$(dirname "$0")/sprint-detect.sh"
#        detect_sprint "$PROJECT_KEY"
# Outputs: ACTIVE_SPRINT_NAME, ACTIVE_SPRINT_ID (exported)

detect_sprint() {
  local project_key="${1:?Usage: detect_sprint <PROJECT_KEY>}"
  
  # JQL to find issues in active sprint
  local jql="project = ${project_key} AND sprint in openSprints() ORDER BY rank ASC"
  
  echo "[sprint-detect] Querying active sprint for ${project_key}..." >&2
  echo "$jql"
}

# Export function for sourcing
export -f detect_sprint 2>/dev/null || true
