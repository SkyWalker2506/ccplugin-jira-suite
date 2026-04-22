#!/usr/bin/env bash
# run_tests.sh — jira-suite bash unit test runner.
# Usage: ./tests/run_tests.sh [test_file_pattern]
# Example: ./tests/run_tests.sh              # run all tests
#          ./tests/run_tests.sh test_retry   # run matching file

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# ---------------------------------------------------------------------------
# Test framework
# ---------------------------------------------------------------------------
_PASS=0
_FAIL=0
_SKIP=0
_CURRENT_SUITE=""

suite() {
  _CURRENT_SUITE="$1"
  echo ""
  echo "  ── ${_CURRENT_SUITE} ──"
}

assert_eq() {
  local desc="$1" expected="$2" actual="$3"
  if [[ "$expected" == "$actual" ]]; then
    echo "    ✓ ${desc}"
    _PASS=$((_PASS + 1))
  else
    echo "    ✗ ${desc}"
    echo "      expected: $(printf '%q' "$expected")"
    echo "      actual:   $(printf '%q' "$actual")"
    _FAIL=$((_FAIL + 1))
  fi
}

assert_contains() {
  local desc="$1" needle="$2" haystack="$3"
  if [[ "$haystack" == *"$needle"* ]]; then
    echo "    ✓ ${desc}"
    _PASS=$((_PASS + 1))
  else
    echo "    ✗ ${desc}"
    echo "      needle:   $(printf '%q' "$needle")"
    echo "      haystack: $(printf '%q' "$haystack")"
    _FAIL=$((_FAIL + 1))
  fi
}

assert_exit_ok() {
  local desc="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    echo "    ✓ ${desc}"
    _PASS=$((_PASS + 1))
  else
    echo "    ✗ ${desc} (exit $?)"
    _FAIL=$((_FAIL + 1))
  fi
}

assert_exit_fail() {
  local desc="$1"
  shift
  if ! "$@" >/dev/null 2>&1; then
    echo "    ✓ ${desc}"
    _PASS=$((_PASS + 1))
  else
    echo "    ✗ ${desc} (expected failure but got 0)"
    _FAIL=$((_FAIL + 1))
  fi
}

skip() {
  echo "    ⊘ SKIP: $1"
  _SKIP=$((_SKIP + 1))
}

# ---------------------------------------------------------------------------
# Discover and run test files
# ---------------------------------------------------------------------------
PATTERN="${1:-test_}"

echo ""
echo "jira-suite test runner"
echo "======================"

for test_file in "${SCRIPT_DIR}/${PATTERN}"*.sh; do
  [[ -f "$test_file" ]] || continue
  # shellcheck source=/dev/null
  source "$test_file"
done

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
TOTAL=$((_PASS + _FAIL + _SKIP))
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Results: ${TOTAL} tests — ${_PASS} passed, ${_FAIL} failed, ${_SKIP} skipped"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [[ $_FAIL -gt 0 ]]; then
  exit 1
fi
exit 0
