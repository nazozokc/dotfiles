---
name: merge-main
description: >
  Use this skill whenever the user wants to merge the main branch into their current branch.
  Triggers include phrases like "merge main", "mainをマージ", "mainを取り込む", "mainに追従",
  "sync with main", "mainの変更を取り込みたい", or any request to bring changes from main
  into a feature/working branch. Always use this skill — do not improvise git commands without it.
---

# merge-main

Procedure for merging changes from the `main` branch into the current working branch.

## Workflow

### Step 1: Check current state

```bash
git status
git branch --show-current
```

- If there are uncommitted changes, prompt the user to stash or commit them first
- Confirm the current branch is not `main` itself

### Step 2: Fetch latest main

```bash
git fetch origin main
```

Use `fetch` instead of `pull` to retrieve the latest without modifying local state.

### Step 3: Review diff before merging

```bash
git log HEAD..origin/main --oneline
git diff HEAD...origin/main --stat
```

- Show the user which commits will be brought in
- If the diff is large, prompt the user to review file by file
- If already up-to-date, stop here

### Step 4: Run the merge

```bash
git merge origin/main --no-ff -m "Merge branch 'main' into $(git branch --show-current)"
```

- Always use `--no-ff` to create a merge commit
- The commit message may be adjusted as appropriate

### Step 5: Handle conflicts

If conflicts occur, choose based on the situation:

#### Pattern A: Simple conflict (attempt auto-resolution)

- Both branches made changes with the same intent
- It is clear which side should take priority
- Propose `git checkout --ours` / `--theirs` after confirming with the user

#### Pattern B: Complex conflict (guide user to resolve)

- The conflict involves intertwined logic
- Show the files with conflict markers and walk the user through resolution

```bash
# Check conflicting files
git diff --name-only --diff-filter=U

# After resolving
git add <resolved-files>
git merge --continue
```

To abort the merge:

```bash
git merge --abort
```

### Step 6: Verify after merge

```bash
git log --oneline -5
git status
```

If everything looks good, suggest pushing to the user.

### Step 7: Push

```bash
git push origin $(git branch --show-current)
```

Never suggest force push — it is unnecessary when a merge commit exists.

---

## Notes

- If called while on the `main` branch, warn the user and stop
- If the remote is not `origin`, confirm with the user before proceeding
- After merging, add a note encouraging the user to run CI or tests
