#!/usr/bin/env bash
# test_prereq_check.sh — Unit tests for validate_project_key and validate_issue_key
# from scripts/prereq-check.sh.
#
# Strategy: extract only the function definitions, avoiding the top-level checks
# (JIRA_CONFIG lookup, secrets check, etc.) that would fail in a test environment.

SCRIPTS_DIR="${REPO_ROOT}/scripts"

# Source only the function definitions from prereq-check.sh.
# We use grep+eval to pull out the two validate_* functions without running
# the top-level side-effecting code.
_load_validators() {
  # Stub colors so the sourced file doesn't fail on missing colors.sh
  ok()  { :; }
  err() { echo "ERROR: $*" >&2; }
  warn(){ echo "WARN: $*"  >&2; }

  # Extract and eval the two functions from prereq-check.sh
  eval "$(awk '/^validate_project_key\(\)/,/^\}/' "${SCRIPTS_DIR}/prereq-check.sh")"
  eval "$(awk '/^validate_issue_key\(\)/,/^\}/'   "${SCRIPTS_DIR}/prereq-check.sh")"
}

_load_validators

# ---------------------------------------------------------------------------
# validate_project_key
# ---------------------------------------------------------------------------

suite "validate_project_key — valid keys"

_exit_code=0; ( validate_project_key "JS"    2>/dev/null ) || _exit_code=$?
assert_eq "JS is valid" "0" "${_exit_code}"

_exit_code=0; ( validate_project_key "VOC"   2>/dev/null ) || _exit_code=$?
assert_eq "VOC is valid" "0" "${_exit_code}"

_exit_code=0; ( validate_project_key "MYAPP" 2>/dev/null ) || _exit_code=$?
assert_eq "MYAPP is valid" "0" "${_exit_code}"

_exit_code=0; ( validate_project_key "AB"    2>/dev/null ) || _exit_code=$?
assert_eq "AB is valid (2 chars)" "0" "${_exit_code}"

_exit_code=0; ( validate_project_key "A0B1C2D3E4" 2>/dev/null ) || _exit_code=$?
assert_eq "10-char key is valid" "0" "${_exit_code}"

suite "validate_project_key — invalid keys"

_exit_code=0; ( validate_project_key ""         2>/dev/null ) || _exit_code=$?
assert_eq "empty key fails" "1" "${_exit_code}"

_exit_code=0; ( validate_project_key "js"        2>/dev/null ) || _exit_code=$?
assert_eq "lowercase key fails" "1" "${_exit_code}"

_exit_code=0; ( validate_project_key "1JS"       2>/dev/null ) || _exit_code=$?
assert_eq "digit-start fails" "1" "${_exit_code}"

_exit_code=0; ( validate_project_key "A"         2>/dev/null ) || _exit_code=$?
assert_eq "single-char key fails (min 2)" "1" "${_exit_code}"

_exit_code=0; ( validate_project_key "TOOLONGKEY1" 2>/dev/null ) || _exit_code=$?
assert_eq "11-char key fails (max 10)" "1" "${_exit_code}"

_exit_code=0; ( validate_project_key "JS-10"    2>/dev/null ) || _exit_code=$?
assert_eq "issue-key format fails for project-key" "1" "${_exit_code}"

# ---------------------------------------------------------------------------
# validate_issue_key
# ---------------------------------------------------------------------------

suite "validate_issue_key — valid keys"

_exit_code=0; ( validate_issue_key "JS-10"    2>/dev/null ) || _exit_code=$?
assert_eq "JS-10 is valid" "0" "${_exit_code}"

_exit_code=0; ( validate_issue_key "VOC-999"  2>/dev/null ) || _exit_code=$?
assert_eq "VOC-999 is valid" "0" "${_exit_code}"

_exit_code=0; ( validate_issue_key "MYAPP-1"  2>/dev/null ) || _exit_code=$?
assert_eq "MYAPP-1 is valid" "0" "${_exit_code}"

suite "validate_issue_key — invalid keys"

_exit_code=0; ( validate_issue_key ""          2>/dev/null ) || _exit_code=$?
assert_eq "empty issue key fails" "1" "${_exit_code}"

_exit_code=0; ( validate_issue_key "js-10"    2>/dev/null ) || _exit_code=$?
assert_eq "lowercase issue key fails" "1" "${_exit_code}"

_exit_code=0; ( validate_issue_key "JS10"     2>/dev/null ) || _exit_code=$?
assert_eq "missing dash fails" "1" "${_exit_code}"

_exit_code=0; ( validate_issue_key "JS-"      2>/dev/null ) || _exit_code=$?
assert_eq "key with no number fails" "1" "${_exit_code}"

_exit_code=0; ( validate_issue_key "1JS-10"   2>/dev/null ) || _exit_code=$?
assert_eq "digit-start issue key fails" "1" "${_exit_code}"
