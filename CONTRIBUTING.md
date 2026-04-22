# Contributing to jira-suite

Thank you for your interest in contributing. This guide covers how to add commands, test changes, and submit PRs.

## Repository structure

```
ccplugin-jira-suite/
├── commands/          ← Claude Code slash commands (*.md)
├── scripts/           ← Bash/Python helper scripts
├── templates/         ← Jira column templates (columns.json)
├── docs/              ← Documentation and examples
├── tests/             ← Bash unit tests
├── .claude-plugin/    ← Plugin metadata (plugin.json)
├── .github/           ← GitHub templates
└── .demo/             ← Demo data for testing without Jira
```

## Adding a new command

1. Create `commands/jira-<name>.md` with the standard YAML front matter:

```markdown
---
name: jira-<name>
description: "Short description of what this command does."
allowed-tools: ["Bash", "Read", "Write", "mcp__atlassian__*"]
argument-hint: "[args] — description of accepted arguments"
---

## What it does

...

## Arguments

| Input | Behavior |
|-------|----------|
| ... | ... |

## Execution

...
```

2. Follow these conventions:
   - Always validate `PROJECT_KEY` and `ISSUE_KEY` using helpers from `scripts/prereq-check.sh`
   - Use `scripts/retry.sh` for any network calls that may fail transiently
   - Use `scripts/colors.sh` for terminal output (ok/warn/err helpers)
   - Source `scripts/prereq-check.sh` at the top of any script requiring Jira access

3. Update the command table in `README.md`

4. Add an example to `docs/EXAMPLES.md`

## Running tests

```bash
./tests/run_tests.sh          # all tests
./tests/run_tests.sh retry    # only test_retry.sh
```

To add tests for a new script, create `tests/test_<name>.sh`:

```bash
#!/usr/bin/env bash
# test_<name>.sh — tests for scripts/<name>.sh

SCRIPTS_DIR="${REPO_ROOT}/scripts"
source "${SCRIPTS_DIR}/<name>.sh"

suite "<name> — function description"

assert_eq "test description" "expected" "$(some_function arg)"
```

## PR checklist

- [ ] Command follows the YAML front matter format
- [ ] `PROJECT_KEY` / `ISSUE_KEY` inputs are validated
- [ ] Bash scripts use `set -euo pipefail`
- [ ] No secrets or credentials in code
- [ ] Tests added or updated in `tests/`
- [ ] `README.md` command table updated (if new command)
- [ ] `RELEASES.md` entry added (or `bump-version.sh` will handle it)

## Coding conventions

- **Bash scripts:** `#!/usr/bin/env bash`, `set -euo pipefail`, POSIX-compatible regex (no `grep -P`)
- **Python scripts:** `#!/usr/bin/env python3`, type hints encouraged, `sys.path` fix for imports
- **Command files (.md):** Always include `## What it does`, `## Arguments`, `## Execution` sections
- **Error messages:** Use `err "..."` from colors.sh for fatal errors, `warn "..."` for warnings
- **Secrets:** Never hardcode; always read from environment or `secrets.env`

## Version bumping

Use the helper script to bump version and update RELEASES.md:

```bash
./scripts/bump-version.sh 1.6.0 "Sprint 6: Quality & Ecosystem"
```

## Questions?

Open a [GitHub Discussion](https://github.com/SkyWalker2506/ccplugin-jira-suite/discussions) or file an issue using the bug/feature templates.
