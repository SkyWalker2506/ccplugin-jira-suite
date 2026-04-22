#!/usr/bin/env bash
# test_retry.sh — Unit tests for scripts/retry.sh

SCRIPTS_DIR="${REPO_ROOT}/scripts"
source "${SCRIPTS_DIR}/retry.sh"

suite "retry.sh — retry_cmd"

# Test: succeeds on first try
_result=$(retry_cmd 3 echo "hello" 2>/dev/null)
assert_eq "succeeds on first try" "hello" "$_result"

# Test: retries on failure and eventually succeeds
_attempts=0
_succeed_after=2
_test_cmd() {
  _attempts=$((_attempts + 1))
  [[ $_attempts -ge $_succeed_after ]]
}
retry_cmd 3 _test_cmd 2>/dev/null
assert_eq "retries until success (attempt count)" "2" "$_attempts"

# Test: returns failure after max retries
_always_fail() { return 1; }
retry_cmd 2 _always_fail 2>/dev/null
assert_eq "returns 1 after max retries" "1" "$?"

# Test: max_retries=1 means one attempt only
_count=0
_counting() { _count=$((_count + 1)); return 1; }
retry_cmd 1 _counting 2>/dev/null
assert_eq "max_retries=1: exactly one attempt" "1" "$_count"
