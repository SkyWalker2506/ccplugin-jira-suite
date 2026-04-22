#!/usr/bin/env bash
# test_dashboard_integration.sh — Integration tests for scripts/dashboard.py
# Invokes dashboard.py from a temp directory to test end-to-end behavior.

SCRIPTS_DIR="${REPO_ROOT}/scripts"
DASHBOARD_PY="${SCRIPTS_DIR}/dashboard.py"

_VALID_CACHE='{"version":2,"updated":"2026-04-22","summary":{"total":3,"todo":1,"in_progress":1,"done":1},"todo":[{"key":"JS-1","summary":"Do something","priority":"Medium","labels":[]}],"in_progress":[{"key":"JS-2","summary":"Doing it","priority":"High","labels":[]}],"done_recent":[{"key":"JS-3","summary":"Done thing"}]}'

_setup_dashboard_fixtures() {
  _DTMPDIR=$(mktemp -d)
  export _DTMPDIR
}

_teardown_dashboard_fixtures() {
  rm -rf "$_DTMPDIR"
}

suite "dashboard.py — valid cache renders successfully"

_setup_dashboard_fixtures
printf '%s' "$_VALID_CACHE" > "${_DTMPDIR}/.jira_cache.json"
_exit_code=0
_out=$(cd "$_DTMPDIR" && python3 "$DASHBOARD_PY" 2>/dev/null) || _exit_code=$?
assert_eq "valid cache exits 0" "0" "${_exit_code}"
assert_contains "output contains JIRA DASHBOARD" "JIRA DASHBOARD" "$_out"
_teardown_dashboard_fixtures

suite "dashboard.py — valid cache shows updated date"

_setup_dashboard_fixtures
printf '%s' "$_VALID_CACHE" > "${_DTMPDIR}/.jira_cache.json"
_out=$(cd "$_DTMPDIR" && python3 "$DASHBOARD_PY" 2>/dev/null)
assert_contains "output shows updated date" "2026-04-22" "$_out"
_teardown_dashboard_fixtures

suite "dashboard.py — missing cache exits 1"

_setup_dashboard_fixtures
_exit_code=0
( cd "$_DTMPDIR" && python3 "$DASHBOARD_PY" 2>/dev/null ) || _exit_code=$?
assert_eq "missing cache exits 1" "1" "${_exit_code}"
_teardown_dashboard_fixtures

suite "dashboard.py — invalid JSON exits 1"

_setup_dashboard_fixtures
printf 'NOT_JSON' > "${_DTMPDIR}/.jira_cache.json"
_exit_code=0
( cd "$_DTMPDIR" && python3 "$DASHBOARD_PY" 2>/dev/null ) || _exit_code=$?
assert_eq "invalid JSON exits 1" "1" "${_exit_code}"
_teardown_dashboard_fixtures

suite "dashboard.py — stale version exits 1"

_setup_dashboard_fixtures
printf '{"version":1,"updated":"2026-04-22","summary":{"total":1,"todo":1,"in_progress":0,"done":0}}' \
  > "${_DTMPDIR}/.jira_cache.json"
_exit_code=0
( cd "$_DTMPDIR" && python3 "$DASHBOARD_PY" 2>/dev/null ) || _exit_code=$?
assert_eq "stale version exits 1" "1" "${_exit_code}"
_teardown_dashboard_fixtures

suite "dashboard.py — stale version reports outdated"

_setup_dashboard_fixtures
printf '{"version":1,"updated":"2026-04-22","summary":{"total":1,"todo":1,"in_progress":0,"done":0}}' \
  > "${_DTMPDIR}/.jira_cache.json"
_out=$(cd "$_DTMPDIR" && python3 "$DASHBOARD_PY" 2>&1 || true)
assert_contains "stale version reports outdated" "outdated" "$_out"
_teardown_dashboard_fixtures

suite "dashboard.py — missing summary key exits 1"

_setup_dashboard_fixtures
printf '{"version":2,"updated":"2026-04-22"}' > "${_DTMPDIR}/.jira_cache.json"
_exit_code=0
( cd "$_DTMPDIR" && python3 "$DASHBOARD_PY" 2>/dev/null ) || _exit_code=$?
assert_eq "missing summary key exits 1" "1" "${_exit_code}"
_teardown_dashboard_fixtures
