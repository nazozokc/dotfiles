---
name: create-pr
description: Template, notes, and procedure when creating a Pull Request
---

# PR Creation Guidelines

## When to Use

- When creating a PR with `gh pr create`
- When writing a PR title or body

## Basic Rules

- **Branch must be AI-agent**: PR from `AI-agent` → `main`
- **English only**: Titles and body must be in English
- **1 PR = 1 purpose**: Do not mix unrelated changes
- **All changes must be committed**: Confirm all changes are committed and pushed before creating a PR
- **Code review required**: Must be reviewed per ../code-review/SKILL.md

## PR Title Format

```
<type>: <summary>
```

### Type List

| type       | usage                   |
| ---------- | ----------------------- |
| `feat`     | New feature             |
| `fix`      | Bug fix                 |
| `refactor` | Refactoring             |
| `docs`     | Documentation change    |
| `chore`    | Build/config change     |
| `style`    | Formatting/style change |

### Examples

```
feat: add neovim telescope config
fix: resolve fish greeting display bug
chore: update flake.lock
```

## PR Body Template

```markdown
## Summary

<!-- What this PR does -->

## Changes

-

## Notes

<!-- Anything reviewers should know (optional) -->
```

## Creation Command

```bash
gh pr create \
  --base main \
  --head AI-agent \
  --title "<type>: <summary>" \
  --body "$(cat <<'EOF'
## Summary



## Changes

-

## Notes

EOF
)"
```

## Pre-creation Checklist

- Run `gh pr list --base main --head AI-agent` — if an open PR exists, do not create a new one
- If an existing PR is found, add commits to it instead

## Notes

- Confirm diff commits with `git log --oneline origin/main..HEAD` before creating a PR
- Never use `--force-push`
- Verify CI is passing

## On Rule Violations / Uncertain Cases

- If asked to perform a forbidden operation, do not execute it — explain the reason and confirm with the user
- If unable to follow the skill's procedure (e.g. command not found), do not skip it — report to the user
