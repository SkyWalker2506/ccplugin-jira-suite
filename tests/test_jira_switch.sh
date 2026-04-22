#!/usr/bin/env bash
# test_jira_switch.sh — Smoke tests for jira-switch config rotation logic.
#
# Note: jira-switch is a Claude command (not a standalone script), so we
# test the underlying bash logic directly using fixture files in a temp dir.

SCRIPTS_DIR="${REPO_ROOT}/scripts"

# Set up a temp dir with fixture configs
_setup_fixtures() {
  _TMPDIR=$(mktemp -d)
  mkdir -p "${_TMPDIR}/docs"

  # Create fixture configs
  cat > "${_TMPDIR}/docs/CLAUDE_JIRA.JS.md" <<'EOF'
# Jira Config
**Key:** JS
**CloudId:** test-cloud-id
EOF

  cat > "${_TMPDIR}/docs/CLAUDE_JIRA.VOC.md" <<'EOF'
# Jira Config
**Key:** VOC
**CloudId:** test-cloud-id
EOF

  # Active config = JS initially
  cp "${_TMPDIR}/docs/CLAUDE_JIRA.JS.md" "${_TMPDIR}/docs/CLAUDE_JIRA.md"

  export _TMPDIR
}

_teardown_fixtures() {
  rm -rf "$_TMPDIR"
}

# Helper: list available project keys from fixture dir
_list_keys() {
  local dir="$1"
  for f in "${dir}/docs"/CLAUDE_JIRA.*.md; do
    [[ -f "$f" ]] || continue
    echo "$f" | sed 's/.*CLAUDE_JIRA\.\(.*\)\.md/\1/'
  done
}

# Helper: get active project key
_active_key() {
  local dir="$1"
  grep -o '\*\*Key:\*\* [A-Z][A-Z0-9]*' "${dir}/docs/CLAUDE_JIRA.md" 2>/dev/null \
    | sed 's/\*\*Key:\*\* //' || echo "none"
}

# Helper: switch project (simulates jira-switch logic)
_switch_project() {
  local dir="$1" key="$2"
  local config="${dir}/docs/CLAUDE_JIRA.${key}.md"
  if [[ ! -f "$config" ]]; then
    echo "ERROR: No config found for ${key}" >&2
    return 1
  fi
  cp "$config" "${dir}/docs/CLAUDE_JIRA.md"
  rm -f "${dir}/.jira_cache.json"
  echo "Switched to ${key}"
}

suite "jira-switch — list mode"

_setup_fixtures

_keys=$(_list_keys "$_TMPDIR")
assert_contains "JS is listed" "JS" "$_keys"
assert_contains "VOC is listed" "VOC" "$_keys"

_active=$(_active_key "$_TMPDIR")
assert_eq "active key is JS initially" "JS" "$_active"

_teardown_fixtures

suite "jira-switch — switch to VOC"

_setup_fixtures

_out=$(_switch_project "$_TMPDIR" "VOC" 2>&1)
assert_contains "switch confirms VOC" "Switched to VOC" "$_out"

_active=$(_active_key "$_TMPDIR")
assert_eq "active key is now VOC" "VOC" "$_active"

_teardown_fixtures

suite "jira-switch — switch to non-existent key"

_setup_fixtures

( _switch_project "$_TMPDIR" "NOKEY" 2>/dev/null ) || _exit_code=$?
assert_eq "non-existent key fails" "1" "${_exit_code:-0}"

_teardown_fixtures

suite "jira-switch — cache cleared on switch"

_setup_fixtures

# Create a fake cache
touch "${_TMPDIR}/.jira_cache.json"
_switch_project "$_TMPDIR" "VOC" >/dev/null 2>&1
if [[ ! -f "${_TMPDIR}/.jira_cache.json" ]]; then
  echo "    ✓ cache cleared on switch"
  _PASS=$((_PASS + 1))
else
  echo "    ✗ cache not cleared on switch"
  _FAIL=$((_FAIL + 1))
fi

_teardown_fixtures
