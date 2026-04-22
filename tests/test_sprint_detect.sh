#!/usr/bin/env bash
# test_sprint_detect.sh — Unit tests for scripts/sprint-detect.sh

SCRIPTS_DIR="${REPO_ROOT}/scripts"
source "${SCRIPTS_DIR}/sprint-detect.sh"

suite "sprint-detect.sh — validate_project_key"

# Valid keys
_out=$(validate_project_key "JS" 2>/dev/null)
assert_eq "valid key JS" "JS" "$_out"

_out=$(validate_project_key "VOC" 2>/dev/null)
assert_eq "valid key VOC" "VOC" "$_out"

_out=$(validate_project_key "MYAPP" 2>/dev/null)
assert_eq "valid key MYAPP" "MYAPP" "$_out"

_out=$(validate_project_key "AB" 2>/dev/null)
assert_eq "valid 2-char key AB" "AB" "$_out"

# Invalid keys — call in subshell; use || true to prevent set -e propagation
( validate_project_key "" 2>/dev/null ) || _exit_code=$?
assert_eq "empty key fails" "1" "${_exit_code:-0}"

( validate_project_key "lowercase" 2>/dev/null ) || _exit_code=$?
assert_eq "lowercase key fails" "1" "${_exit_code:-0}"

( validate_project_key "JS-10" 2>/dev/null ) || _exit_code=$?
assert_eq "issue key format rejected" "1" "${_exit_code:-0}"

( validate_project_key "1BAD" 2>/dev/null ) || _exit_code=$?
assert_eq "starts with digit rejected" "1" "${_exit_code:-0}"

( validate_project_key "TOOLONGKEY123" 2>/dev/null ) || _exit_code=$?
assert_eq "key longer than 10 chars rejected" "1" "${_exit_code:-0}"

suite "sprint-detect.sh — detect_sprint JQL output"

_jql=$(detect_sprint "JS" 2>/dev/null)
assert_contains "JQL contains project key" "project = JS" "$_jql"
assert_contains "JQL uses openSprints()" "openSprints()" "$_jql"
