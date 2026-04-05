#!/usr/bin/env bash
# log-rotate.sh — Rotate jira_loop_log.md to max 500 lines (newest on top).
# Usage: source "$(dirname "$0")/log-rotate.sh"
#        rotate_log "docs/jira_loop_log.md" 500

rotate_log() {
  local log_file="${1:?Usage: rotate_log <file> <max_lines>}"
  local max_lines="${2:-500}"

  if [[ ! -f "$log_file" ]]; then
    return 0
  fi

  local line_count
  line_count=$(wc -l < "$log_file")

  if [[ $line_count -gt $max_lines ]]; then
    # Keep newest max_lines entries
    tail -n "$max_lines" "$log_file" > "${log_file}.tmp"
    mv "${log_file}.tmp" "$log_file"
    echo "[log-rotate] Trimmed $log_file from $line_count to $max_lines lines." >&2
  fi
}
