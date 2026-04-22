#!/usr/bin/env bash
# test_bump_version.sh — Unit tests for scripts/bump-version.sh

SCRIPTS_DIR="${REPO_ROOT}/scripts"
BUMP_SCRIPT="${SCRIPTS_DIR}/bump-version.sh"

# Set up a temp dir with a minimal plugin.json and empty RELEASES.md
_setup_bump_fixtures() {
  _BTMPDIR=$(mktemp -d)
  mkdir -p "${_BTMPDIR}/.claude-plugin" "${_BTMPDIR}/scripts"

  cat > "${_BTMPDIR}/.claude-plugin/plugin.json" <<'EOF'
{
  "name": "test-plugin",
  "version": "1.5.0",
  "description": "Test plugin"
}
EOF

  cat > "${_BTMPDIR}/RELEASES.md" <<'EOF'
# Releases

## v1.5.0 — 2026-01-01
### Initial
- first release
EOF

  # Copy bump-version.sh (it references PLUGIN_JSON and RELEASES_MD via REPO_ROOT)
  cp "${BUMP_SCRIPT}" "${_BTMPDIR}/scripts/bump-version.sh"
  chmod +x "${_BTMPDIR}/scripts/bump-version.sh"

  export _BTMPDIR
}

_teardown_bump_fixtures() {
  rm -rf "$_BTMPDIR"
}

suite "bump-version.sh — invalid semver rejected"

_setup_bump_fixtures
_exit_code=0
( bash "${_BTMPDIR}/scripts/bump-version.sh" "bad-version" 2>/dev/null ) || _exit_code=$?
assert_eq "invalid semver exits non-zero" "1" "${_exit_code}"
_teardown_bump_fixtures

suite "bump-version.sh — missing version argument"

_setup_bump_fixtures
_exit_code=0
( bash "${_BTMPDIR}/scripts/bump-version.sh" 2>/dev/null ) || _exit_code=$?
assert_eq "missing version exits non-zero" "1" "${_exit_code}"
_teardown_bump_fixtures

suite "bump-version.sh — dry-run does not modify files"

_setup_bump_fixtures
bash "${_BTMPDIR}/scripts/bump-version.sh" "1.6.0" --dry-run >/dev/null 2>&1
_ver=$(python3 -c "import json; print(json.load(open('${_BTMPDIR}/.claude-plugin/plugin.json'))['version'])")
assert_eq "dry-run: plugin.json version unchanged" "1.5.0" "$_ver"
_teardown_bump_fixtures

suite "bump-version.sh — dry-run shows would-update message"

_setup_bump_fixtures
_out=$(bash "${_BTMPDIR}/scripts/bump-version.sh" "1.6.0" --dry-run 2>/dev/null)
assert_contains "dry-run mentions plugin.json" ".claude-plugin/plugin.json" "$_out"
assert_contains "dry-run mentions RELEASES.md" "RELEASES.md" "$_out"
_teardown_bump_fixtures

suite "bump-version.sh — valid bump updates plugin.json"

_setup_bump_fixtures
bash "${_BTMPDIR}/scripts/bump-version.sh" "1.6.0" "New Release" >/dev/null 2>&1
_ver=$(python3 -c "import json; print(json.load(open('${_BTMPDIR}/.claude-plugin/plugin.json'))['version'])")
assert_eq "plugin.json version updated to 1.6.0" "1.6.0" "$_ver"
_teardown_bump_fixtures

suite "bump-version.sh — valid bump prepends to RELEASES.md"

_setup_bump_fixtures
bash "${_BTMPDIR}/scripts/bump-version.sh" "1.6.0" "New Release" >/dev/null 2>&1
_first=$(head -1 "${_BTMPDIR}/RELEASES.md")
assert_contains "RELEASES.md starts with new version" "v1.6.0" "$_first"
_teardown_bump_fixtures

suite "bump-version.sh — RELEASES.md preserves existing content"

_setup_bump_fixtures
bash "${_BTMPDIR}/scripts/bump-version.sh" "1.6.0" >/dev/null 2>&1
_content=$(cat "${_BTMPDIR}/RELEASES.md")
assert_contains "old release still present" "v1.5.0" "$_content"
_teardown_bump_fixtures

suite "bump-version.sh — same version is no-op"

_setup_bump_fixtures
_out=$(bash "${_BTMPDIR}/scripts/bump-version.sh" "1.5.0" 2>/dev/null)
assert_contains "same version reports no-op" "already" "$_out"
_teardown_bump_fixtures
