---
name: agent-memory
description: Always refer to this skill at the START of every conversation to retrieve relevant memories. Also refer when saving reusable patterns, user preferences, lessons learned, or memorable knowledge to the agent-memory repository during or after conversations.
---

# Agent Memory

## Purpose

This skill enables the agent to persist important knowledge across sessions by saving structured memory files to `~/ghq/github.com/nazozokc/agent-memory/`.

## When to Use

- During thinking, when a code pattern is likely reusable in future sessions
- When a user preference or style decision is explicitly or implicitly established
- When a lesson is learned from an error or debugging session
- When a command, shortcut, or workflow proves useful
- When project context or environment knowledge should be retained
- When the user explicitly asks to save something to memory

## When NOT to Use

- For trivial one-off information that won't be reused
- For temporary debugging notes
- For information already documented in the project itself (README, comments, etc.)

## Directory Structure

```
~/ghq/github.com/nazozokc/agent-memory/
├── patterns/
├── preferences/
├── lessons/
├── commands/
├── context/
└── <agent-created>/          # Agent creates new categories as needed
```

If no existing category fits, the agent must create a new subdirectory with a descriptive name.

## File Naming

```
YYYY-MM-DD-<session-name>-<agent-name>.md
```

- `YYYY-MM-DD`: Date of creation (ISO 8601)
- `<session-name>`: Auto-derived from the task topic (e.g., `nix-flake-setup`, `neovim-plugin-add`, `fish-function-debug`)
- `<agent-name>`: Name of the agent instance (e.g., `opencode`, `claude`)

Example: `2026-09-11-nix-flake-setup-opencode.md`

## File Format

Every memory file MUST include frontmatter with exactly 3 fields:

```markdown
---
tags: [nix, flake, devshell]
created: 2026-09-11
summary: How to set up a Nix flake devShell for TypeScript projects
---

# <Title>

<Content in markdown>
```

### Frontmatter Fields

- `tags` (array of strings): Keywords for retrieval. Use lowercase, kebab-case. Include both broad and specific terms.
- `created` (string): ISO 8601 date (`YYYY-MM-DD`).
- `summary` (string): One-line description of what this memory contains.

## Retrieval Protocol

At the START of every conversation:

1. Determine the current task topic
2. Extract relevant keywords from the task
3. Use `grep` to search frontmatter `tags` across all memory files:
   ```bash
   grep -rl "keyword" ~/ghq/github.com/nazozokc/agent-memory/ --include="*.md"
   ```
4. Read matching files to inform the current session
5. If no matches, proceed without memory context

## Saving Protocol

When deciding to save a memory:

1. **Determine category**: Choose existing category or create new one
2. **Generate filename**: Use the naming convention above
3. **Write the file** with proper frontmatter
4. **Do NOT git commit/push**: This skill is write-only. The user manages the repo separately.

## Decision Criteria: What to Save

A piece of knowledge is worth saving if:

- It will likely be reused in 3+ future sessions
- The user expressed a strong preference or made a deliberate choice
- A non-obvious solution was found after significant debugging
- A pattern emerged from repeated similar tasks
- The information is not obvious from the codebase alone

A piece of knowledge is NOT worth saving if:

- It is project-specific temporary state
- It is standard language/framework knowledge
- It is already documented in the project files
- It is a trivial one-line fact

## Notes

- Tags should be specific enough to filter but broad enough to catch related queries
- Keep each file focused on a single topic
- Content should be self-contained — another agent reading only this file should understand it
- When in doubt about category, use `context/` as the default
