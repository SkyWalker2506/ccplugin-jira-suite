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

  # Prefer TOKEN_CREATED date recorded by setup-token; fall back to file mtime
  local token_age_days created_line created_epoch now mod_time

  created_line=$(grep -m1 "^# TOKEN_CREATED=" "$SECRETS_FILE" 2>/dev/null | cut -d= -f2)

  if [[ -n "$created_line" ]]; then
    now=$(date +%s)
    if [[ "$(uname)" == "Darwin" ]]; then
      created_epoch=$(date -j -f "%Y-%m-%d" "$created_line" "+%s" 2>/dev/null)
    else
      created_epoch=$(date -d "$created_line" "+%s" 2>/dev/null)
    fi
    if [[ -n "$created_epoch" ]]; then
      token_age_days=$(( (now - created_epoch) / 86400 ))
    else
      echo "⚠ Could not parse TOKEN_CREATED date '$created_line' — falling back to file mtime" >&2
    fi
  fi

  if [[ -z "$token_age_days" ]]; then
    # Fallback: use file modification time as proxy for token creation
    now=$(date +%s)
    if [[ "$(uname)" == "Darwin" ]]; then
      mod_time=$(stat -f %m "$SECRETS_FILE")
    else
      mod_time=$(stat -c %Y "$SECRETS_FILE")
    fi
    token_age_days=$(( (now - mod_time) / 86400 ))
  fi

  local remaining=$((365 - token_age_days))

  if [[ $remaining -le 0 ]]; then
    echo "✗ API token likely EXPIRED (token is ${token_age_days} days old). Rotate now:" >&2
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
