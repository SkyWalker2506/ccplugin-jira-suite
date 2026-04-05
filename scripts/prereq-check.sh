#!/usr/bin/env bash
# prereq-check.sh — Common prerequisite checks for jira-suite commands.
# Source this file at the top of any script that needs Jira access.
#
# Usage: source "$(dirname "$0")/prereq-check.sh"

set -euo pipefail

# Source shared colors
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/colors.sh"

# Check required commands
for cmd in python3 curl jq; do
  if ! command -v "$cmd" &>/dev/null; then
    err "Required command not found: $cmd"
    err "Install it and try again."
    exit 1
  fi
done

# Check CLAUDE_JIRA.md exists
JIRA_CONFIG=""
for path in "docs/CLAUDE_JIRA.md" "CLAUDE_JIRA.md"; do
  if [[ -f "$path" ]]; then
    JIRA_CONFIG="$path"
    break
  fi
done

if [[ -z "$JIRA_CONFIG" ]]; then
  err "No Jira config found. Run /jira-init to set up."
  exit 1
fi

# Extract PROJECT_KEY from config
PROJECT_KEY=$(grep -oP '(?<=\*\*Key:\*\* )\S+' "$JIRA_CONFIG" 2>/dev/null || true)
if [[ -z "$PROJECT_KEY" ]]; then
  err "Could not extract PROJECT_KEY from $JIRA_CONFIG"
  exit 1
fi

# Validate PROJECT_KEY format
if [[ ! "$PROJECT_KEY" =~ ^[A-Z][A-Z0-9]{1,9}$ ]]; then
  err "Invalid PROJECT_KEY format: $PROJECT_KEY (expected: uppercase letters/numbers, 2-10 chars)"
  exit 1
fi

# Export for downstream use
export JIRA_CONFIG PROJECT_KEY

ok "Config: $JIRA_CONFIG | Project: $PROJECT_KEY"
