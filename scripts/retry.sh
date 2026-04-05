#!/usr/bin/env bash
# retry.sh — Exponential backoff retry wrapper for jira-suite.
# Source this file to use retry_cmd function.
#
# Usage: source "$(dirname "$0")/retry.sh"
#        retry_cmd 3 curl -s -H ...

retry_cmd() {
  local max_retries="${1:?Usage: retry_cmd <max_retries> <command...>}"
  shift
  local attempt=0
  local delay=2

  while [ $attempt -lt $max_retries ]; do
    if "$@"; then
      return 0
    fi
    attempt=$((attempt + 1))
    if [ $attempt -lt $max_retries ]; then
      echo "[retry] Attempt $attempt/$max_retries failed. Waiting ${delay}s..." >&2
      sleep $delay
      delay=$((delay * 2))
    fi
  done

  echo "[retry] All $max_retries attempts failed." >&2
  return 1
}
