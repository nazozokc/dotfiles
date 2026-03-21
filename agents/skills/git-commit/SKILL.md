---
name: git-commit
description: Rules for Git commits, pushes, and PR creation
---

# Git Operation Guidelines

## When to Use

- When committing files
- When pushing to remote

## Basic Rules

- **No Japanese in commits**: English only
- **1 commit = 1 logical change**: Do not mix multiple different changes
- **Meaningful granularity**: Split large changes
- **Branch must always be AI-agent**: Always commit and push to AI-agent
- **Code review before committing**: See ../code-review/SKILL.md

## Branch Strategy

- **Working branch**: Always use `AI-agent`
- **PR target**: Merge `AI-agent` → `main`
- **Branch creation**: If `AI-agent` doesn't exist, create it first

## Commit Message Format

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
refactor: simplify home-manager modules
```

## Notes

- Run `git status` before committing to confirm changes
- Auto-generated files should be committed separately
- Never use `--force` variants before creating a PR
