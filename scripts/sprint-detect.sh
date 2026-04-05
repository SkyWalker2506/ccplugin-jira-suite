#!/usr/bin/env bash
# sprint-detect.sh — Validate project key and emit JQL for active sprint detection.
#
# Usage (as utility / sourced):
#   source "$(dirname "$0")/sprint-detect.sh"
#   detect_sprint "JS"          # prints JQL to stdout, exports vars on success
#
# Usage (standalone — wraps MCP via claude CLI if available):
#   ./scripts/sprint-detect.sh JS
#
# Outputs (exported):
#   ACTIVE_SPRINT_JQL   — Safe JQL string for MCP searchJiraIssuesUsingJql
#   SPRINT_PROJECT_KEY  — Validated project key
#
# Security: PROJECT_KEY is validated against [A-Z][A-Z0-9]{1,9} before
# being interpolated into any JQL string, preventing JQL injection.

set -euo pipefail

# ---------------------------------------------------------------------------
# validate_project_key — Returns 0 and echoes sanitised key, or exits 1.
# Accepts only: uppercase letters and digits, 2-10 chars, starting with letter.
# ---------------------------------------------------------------------------
validate_project_key() {
  local raw="${1:-}"
  if [[ -z "$raw" ]]; then
    echo "[sprint-detect] ERROR: PROJECT_KEY is required." >&2
    return 1
  fi

  # Strip surrounding whitespace
  local key
  key="$(echo "$raw" | tr -d '[:space:]')"

  # Enforce safe pattern — prevents JQL injection via special chars
  if [[ ! "$key" =~ ^[A-Z][A-Z0-9]{1,9}$ ]]; then
    echo "[sprint-detect] ERROR: Invalid PROJECT_KEY '${key}'. Must match ^[A-Z][A-Z0-9]{1,9}$." >&2
    return 1
  fi

  echo "$key"
}

# ---------------------------------------------------------------------------
# detect_sprint — Main function.
# Sets ACTIVE_SPRINT_JQL and SPRINT_PROJECT_KEY; prints JQL to stdout.
# ---------------------------------------------------------------------------
detect_sprint() {
  local raw_key="${1:-}"

  local project_key
  project_key="$(validate_project_key "$raw_key")" || exit 1

  # Build safe JQL — project_key is validated above, safe to interpolate
  local jql="project = ${project_key} AND sprint in openSprints() ORDER BY rank ASC"

  export SPRINT_PROJECT_KEY="$project_key"
  export ACTIVE_SPRINT_JQL="$jql"

  echo "[sprint-detect] Project key validated: ${project_key}" >&2
  echo "[sprint-detect] JQL: ${jql}" >&2
  echo "$jql"
}

# ---------------------------------------------------------------------------
# Standalone execution — emit JQL; callers pipe to MCP or parse output.
# When sourced, only the functions above are loaded.
# ---------------------------------------------------------------------------
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  PROJECT_KEY="${1:-}"
  detect_sprint "$PROJECT_KEY"
fi

# Export for sourcing in bash environments (no-op in zsh)
export -f detect_sprint validate_project_key 2>/dev/null || true
