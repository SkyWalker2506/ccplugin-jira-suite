#!/usr/bin/env bash
# bump-version.sh — Bump jira-suite version in plugin.json and RELEASES.md.
#
# Usage:
#   ./scripts/bump-version.sh <new-version> [release-title]
#   ./scripts/bump-version.sh 1.6.0
#   ./scripts/bump-version.sh 1.6.0 "Sprint 6: Quality & Ecosystem"
#
# What it does:
#   1. Validates semver format (X.Y.Z)
#   2. Updates "version" in .claude-plugin/plugin.json
#   3. Prepends a new section to RELEASES.md
#   4. Optionally creates a git tag (--tag flag)
#
# Options:
#   --tag     Create a git tag v{new-version} after bumping
#   --dry-run Show what would change without writing anything

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

PLUGIN_JSON="${REPO_ROOT}/.claude-plugin/plugin.json"
RELEASES_MD="${REPO_ROOT}/RELEASES.md"

# ---------------------------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------------------------
NEW_VERSION=""
RELEASE_TITLE=""
CREATE_TAG=false
DRY_RUN=false

for arg in "$@"; do
  case "$arg" in
    --tag)      CREATE_TAG=true ;;
    --dry-run)  DRY_RUN=true ;;
    [0-9]*.[0-9]*.[0-9]*)  NEW_VERSION="$arg" ;;
    *)          [[ -n "$NEW_VERSION" ]] && RELEASE_TITLE="$arg" ;;
  esac
done

if [[ -z "$NEW_VERSION" ]]; then
  echo "Usage: ./scripts/bump-version.sh <version> [title] [--tag] [--dry-run]"
  echo "Example: ./scripts/bump-version.sh 1.6.0 'Sprint 6: Quality & Ecosystem'"
  exit 1
fi

# Validate semver format
if [[ ! "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "✗ Invalid version format: '${NEW_VERSION}' (expected X.Y.Z, e.g. 1.6.0)"
  exit 1
fi

# ---------------------------------------------------------------------------
# Read current version
# ---------------------------------------------------------------------------
CURRENT_VERSION=$(python3 -c "import json; print(json.load(open('${PLUGIN_JSON}'))['version'])")
TODAY=$(date +%Y-%m-%d)

if [[ "$CURRENT_VERSION" == "$NEW_VERSION" ]]; then
  echo "⚠ Version is already ${NEW_VERSION} — nothing to bump."
  exit 0
fi

echo "Bumping: ${CURRENT_VERSION} → ${NEW_VERSION}"
[[ -n "$RELEASE_TITLE" ]] && echo "Title:   ${RELEASE_TITLE}"
echo "Date:    ${TODAY}"
[[ "$CREATE_TAG" == "true" ]] && echo "Tag:     v${NEW_VERSION}"
[[ "$DRY_RUN" == "true" ]]  && echo "(dry-run — no files modified)"
echo ""

if [[ "$DRY_RUN" == "true" ]]; then
  echo "Would update: ${PLUGIN_JSON}"
  echo "Would prepend to: ${RELEASES_MD}"
  [[ "$CREATE_TAG" == "true" ]] && echo "Would tag: v${NEW_VERSION}"
  exit 0
fi

# ---------------------------------------------------------------------------
# Update plugin.json version
# ---------------------------------------------------------------------------
python3 - <<PYEOF
import json
path = '${PLUGIN_JSON}'
data = json.load(open(path))
data['version'] = '${NEW_VERSION}'
with open(path, 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write('\n')
PYEOF

echo "✓ Updated ${PLUGIN_JSON}"

# ---------------------------------------------------------------------------
# Prepend to RELEASES.md
# ---------------------------------------------------------------------------
TITLE="${RELEASE_TITLE:-v${NEW_VERSION}}"

# Build new section
NEW_SECTION="## v${NEW_VERSION} — ${TODAY}
### ${TITLE}
- (add release notes here)

"

# Prepend to RELEASES.md (preserve existing content)
EXISTING=$(cat "${RELEASES_MD}")
printf '%s\n%s' "$NEW_SECTION" "$EXISTING" > "${RELEASES_MD}"

echo "✓ Prepended section to ${RELEASES_MD}"

# ---------------------------------------------------------------------------
# Create git tag (optional)
# ---------------------------------------------------------------------------
if [[ "$CREATE_TAG" == "true" ]]; then
  TAG="v${NEW_VERSION}"
  git -C "${REPO_ROOT}" tag -a "$TAG" -m "Release ${TAG}: ${TITLE}"
  echo "✓ Created git tag ${TAG}"
  echo "  Push with: git push origin ${TAG}"
fi

echo ""
echo "Done. Edit RELEASES.md to add release notes, then commit."
