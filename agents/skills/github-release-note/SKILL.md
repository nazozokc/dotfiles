---
name: github-release-notes
description: Automatically generate GitHub release notes from git log commit history or CHANGELOG.md. Use this skill whenever the user says "write release notes", "generate a changelog", "create release notes for v1.0.0", or "I want to make a release document from git log". Supports Conventional Commits (feat:, fix:, perf:, etc.).
---

# GitHub Release Notes Skill

Generates GitHub Releases-formatted Markdown from `git log` output or an existing `CHANGELOG.md`.

## Accepted Inputs

- `git log` output (`--oneline` or verbose format)
- Contents of a `CHANGELOG.md`
- A commit range (e.g., `v0.1.0..HEAD`)
- A commit list pasted directly by the user

If no input is provided, guide the user to run:

```bash
# List commits since the last tag
git log <previous-tag>..HEAD --oneline

# Or with more detail
git log <previous-tag>..HEAD --pretty=format:"%h %s (%an)"
```

---

## Processing Steps

### 1. Classify Commits

Categorize commits based on Conventional Commits prefixes:

| Prefix                    | Section                              |
| ------------------------- | ------------------------------------ |
| `feat:`, `feat(scope):`   | ✨ Features                          |
| `fix:`, `fix(scope):`     | 🐛 Bug Fixes                         |
| `perf:`, `perf(scope):`   | ⚡ Performance                       |
| `docs:`                   | 📝 Documentation (optional)          |
| `refactor:`               | ♻️ Refactoring (optional)            |
| `chore:`, `build:`, `ci:` | 🔧 Chores (usually omitted)          |
| `BREAKING CHANGE`         | 💥 Breaking Changes (always include) |

For non-Conventional Commits, infer the appropriate section from the message content. Skip obviously trivial commits (`fix typo`, `wip`, etc.).

### 2. Message Formatting Rules

- Write in **English**
- Rephrase commit messages in user-friendly language rather than copying them verbatim
- Include scope context (e.g. `feat(plugin):` → mention the plugin name) where helpful
- Summarize overly long messages
- Group multiple commits touching the same feature into a single bullet

### 3. Output Format

```markdown
## vX.Y.Z (YYYY-MM-DD)

### ✨ Features

- Feature description ([`abc1234`](https://github.com/<owner>/<repo>/commit/abc1234))

### 🐛 Bug Fixes

- Bug fix description ([`def5678`](https://github.com/<owner>/<repo>/commit/def5678))

### ⚡ Performance

- Performance improvement description

<!-- only if applicable -->

### 💥 Breaking Changes

- What changed and how to migrate

### 📦 Full Changelog

**Full Changelog**: https://github.com/<owner>/<repo>/compare/v0.0.1...v1.0.0
```

**Only include sections that have at least one relevant commit.**

---

## Additional Rules

- If owner/repo is unknown, use `<owner>/<repo>` as a placeholder and tell the user to replace it
- If the version number is unknown, ask the user before generating
- Use today's date unless the user specifies otherwise
- If `CHANGELOG.md` is provided as input, match its style for consistency
- Always highlight Breaking Changes clearly; include migration steps if applicable

---

## Example Output

```markdown
## v0.2.0 (2026-03-21)

### ✨ Features

- Add custom ASCII art to snacks.nvim dashboard ([`3a1f2b0`](https://github.com/nazozokc/NazoVim/commit/3a1f2b0))
- Integrate typescript-tools.nvim for improved tsserver resolution ([`7c4d8e1`](https://github.com/nazozokc/NazoVim/commit/7c4d8e1))

### 🐛 Bug Fixes

- Fix duplicate notifications by replacing nvim-notify with snacks notifier ([`2b9f3a4`](https://github.com/nazozokc/NazoVim/commit/2b9f3a4))

### ⚡ Performance

- Optimize startup time to ~55ms by reworking lazy loading ([`8e1c5d2`](https://github.com/nazozokc/NazoVim/commit/8e1c5d2))

### 📦 Full Changelog

**Full Changelog**: https://github.com/nazozokc/NazoVim/compare/v0.1.0...v0.2.0
```
