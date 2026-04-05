#!/usr/bin/env bash
# token-check.sh — Check Jira API token age and warn if older than 335 days.
# Atlassian API tokens expire after 365 days.
# Usage: source "$(dirname "$0")/token-check.sh"
#        check_token_age

SECRETS_FILE="$HOME/.claude/secrets/secrets.env"

check_token_age() {
  if [[ ! -f "$SECRETS_FILE" ]]; then
    echo "⚠ No secrets file found at $SECRETS_FILE" >&2
    return 1
  fi

  # Check file modification time as proxy for token creation
  local file_age_days
  if [[ "$(uname)" == "Darwin" ]]; then
    local mod_time
    mod_time=$(stat -f %m "$SECRETS_FILE")
    local now
    now=$(date +%s)
    file_age_days=$(( (now - mod_time) / 86400 ))
  else
    file_age_days=$(( ($(date +%s) - $(stat -c %Y "$SECRETS_FILE")) / 86400 ))
  fi

  local remaining=$((365 - file_age_days))

  if [[ $remaining -le 0 ]]; then
    echo "✗ API token likely EXPIRED (file is ${file_age_days} days old). Rotate now:" >&2
    echo "  → https://id.atlassian.com/manage-profile/security/api-tokens" >&2
    return 2
  elif [[ $remaining -le 30 ]]; then
    echo "⚠ API token expires in ~${remaining} days. Consider rotating:" >&2
    echo "  → https://id.atlassian.com/manage-profile/security/api-tokens" >&2
    return 0
  fi

  return 0
}

# Functions are defined above; source this file to use them in subshells.
