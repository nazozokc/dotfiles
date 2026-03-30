---
name: merge-main
description: When merging main branch into current working branch
---

# Merge Main Branch Guidelines

## When to Use

- When user asks to merge main into current branch
- When updating feature branch with latest main changes
- When syncing current branch with main

## Basic Rules

- **Always fetch latest main first**: `git fetch origin main`
- **Stash or commit current changes**: Ensure working tree is clean before merging
- **Use merge (not rebase)**: Preserve merge history
- **Resolve conflicts manually**: Never use `--no-commit` unless necessary
- **Test after merge**: Run build/lint if available

## Workflow

1. Stash current changes: `git stash`
2. Switch to main: `git checkout main`
3. Pull latest: `git pull origin main`
4. Switch back: `git checkout -`
5. Merge main: `git merge main`
6. Resolve conflicts if any
7. Commit merge: `git commit`

## Notes

- Never force push after merge
- If conflicts exist, ask user how to resolve
- Use `git mergetool` for visual conflict resolution if available
