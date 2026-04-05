#!/usr/bin/env bash
# audit-log.sh — Append admin operation to audit log.
# Usage: source "$(dirname "$0")/audit-log.sh"
#        audit_log "create-project" "KEY=JS, NAME=Jira Suite"

AUDIT_FILE="docs/audit_log.md"

audit_log() {
  local operation="${1:?Usage: audit_log <operation> <details>}"
  local details="${2:-}"
  local timestamp
  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  local user
  user=$(git config user.name 2>/dev/null || echo "unknown")

  mkdir -p "$(dirname "$AUDIT_FILE")"

  # Create header if file doesn't exist
  if [[ ! -f "$AUDIT_FILE" ]]; then
    cat > "$AUDIT_FILE" << 'HEADER'
# Audit Log — Jira Admin Operations

| Timestamp | User | Operation | Details |
|-----------|------|-----------|---------|
HEADER
  fi

  echo "| ${timestamp} | ${user} | ${operation} | ${details} |" >> "$AUDIT_FILE"
}

export -f audit_log 2>/dev/null || true
