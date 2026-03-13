---
name: github-actions
description: When creating, editing, or debugging GitHub Actions workflow YAML files
---

# GitHub Actions Guidelines

## When to Use

- When creating or editing `.github/workflows/*.yml`
- When debugging CI failures

## Basic Rules

- **Always run actionlint**: Validate with `actionlint` after creating or editing a workflow
- **Use exact runner names**: Use official names like `ubuntu-latest` / `ubuntu-24.04`
- **ShellCheck compliance**: Watch for SC2148 and SC2155 in `run:` blocks
- **Respect exit codes**: Don't suppress with `|| true` — fix the root cause

## Runner Name Cheatsheet

| Use Case     | Runner Name     |
| ------------ | --------------- |
| Latest Linux | `ubuntu-latest` |
| Pinned Linux | `ubuntu-24.04`  |
| macOS        | `macos-latest`  |

## Common Mistakes and Fixes

| Mistake                               | Fix                                                                |
| ------------------------------------- | ------------------------------------------------------------------ |
| Wrong `runs-on` runner name           | Check the cheatsheet above                                         |
| SC2155: declare and assign separately | Split into `local var; var=$(cmd)`                                 |
| SC2148: missing shebang               | Not needed for inline scripts; add `#!/usr/bin/env bash` for files |
| luacheck exits non-zero               | Check `--no-unused-args` option or `.luacheckrc`                   |

## flake.lock Auto-update PR

- Uses `nazozokc-updater-bot`
- Branch name: `update/flake-lock-YYYYMMDD`
- Auto-merge: Managed separately from Renovate

## Notes

- Only use `${{ secrets.NAME }}` format for secrets
- Verify `github.event_name` carefully in `if:` conditions
- Matrix builds increase diff size — confirm before changing

## On Rule Violations / Uncertain Cases

- If asked to perform a forbidden operation, do not execute it — explain the reason and confirm with the user
- If unable to follow the skill's procedure (e.g. command not found), do not skip it — report to the user
