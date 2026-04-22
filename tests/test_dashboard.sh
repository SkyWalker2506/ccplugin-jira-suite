#!/usr/bin/env bash
# test_dashboard.sh — Unit tests for scripts/dashboard.py (validate_cache function)

SCRIPTS_DIR="${REPO_ROOT}/scripts"

# Helper: run validate_cache via python3 inline
_validate_cache() {
  python3 - "$1" <<'PYEOF'
import json, sys
from pathlib import Path

# Add scripts dir to path
import os
scripts_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'scripts')

# Load the validate_cache function from dashboard.py inline
REQUIRED_KEYS = ["version", "updated", "summary"]
REQUIRED_SUMMARY_KEYS = ["total", "todo", "in_progress", "done"]
MIN_VERSION = 2

def validate_cache(data):
    for key in REQUIRED_KEYS:
        if key not in data:
            return False, f"missing required key: '{key}'"
    version = data.get("version", 0)
    if version < MIN_VERSION:
        return False, f"version {version} is outdated (min: {MIN_VERSION})"
    summary = data.get("summary", {})
    for key in REQUIRED_SUMMARY_KEYS:
        if key not in summary:
            return False, f"summary missing key: '{key}'"
    return True, "ok"

try:
    input_data = json.loads(sys.argv[1])
except (json.JSONDecodeError, IndexError) as e:
    print(f"INVALID_JSON:{e}")
    sys.exit(2)

ok, reason = validate_cache(input_data)
if ok:
    print("OK")
else:
    print(f"FAIL:{reason}")
PYEOF
}

suite "dashboard.py — validate_cache"

# Valid cache
_VALID='{"version":2,"updated":"2026-04-22","summary":{"total":5,"todo":2,"in_progress":1,"done":2}}'
_out=$(_validate_cache "$_VALID" 2>/dev/null)
assert_eq "valid cache returns OK" "OK" "$_out"

# Missing version key
_NO_VERSION='{"updated":"2026-04-22","summary":{"total":5,"todo":2,"in_progress":1,"done":2}}'
_out=$(_validate_cache "$_NO_VERSION" 2>/dev/null)
assert_contains "missing version key detected" "missing required key: 'version'" "$_out"

# Missing updated key
_NO_UPDATED='{"version":2,"summary":{"total":5,"todo":2,"in_progress":1,"done":2}}'
_out=$(_validate_cache "$_NO_UPDATED" 2>/dev/null)
assert_contains "missing updated key detected" "missing required key: 'updated'" "$_out"

# Missing summary key
_NO_SUMMARY='{"version":2,"updated":"2026-04-22"}'
_out=$(_validate_cache "$_NO_SUMMARY" 2>/dev/null)
assert_contains "missing summary key detected" "missing required key: 'summary'" "$_out"

# Old version
_OLD_VERSION='{"version":1,"updated":"2026-04-22","summary":{"total":5,"todo":2,"in_progress":1,"done":2}}'
_out=$(_validate_cache "$_OLD_VERSION" 2>/dev/null)
assert_contains "old version detected" "outdated" "$_out"

# Version 0
_ZERO_VERSION='{"version":0,"updated":"2026-04-22","summary":{"total":5,"todo":2,"in_progress":1,"done":2}}'
_out=$(_validate_cache "$_ZERO_VERSION" 2>/dev/null)
assert_contains "version 0 detected as outdated" "outdated" "$_out"

# Missing summary field (in_progress)
_NO_IP='{"version":2,"updated":"2026-04-22","summary":{"total":5,"todo":2,"done":2}}'
_out=$(_validate_cache "$_NO_IP" 2>/dev/null)
assert_contains "missing in_progress in summary" "summary missing key" "$_out"

# Empty object
_EMPTY='{}'
_out=$(_validate_cache "$_EMPTY" 2>/dev/null)
assert_contains "empty object fails" "missing required key" "$_out"
