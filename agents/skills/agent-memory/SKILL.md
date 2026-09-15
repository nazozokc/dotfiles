---
name: agent-memory
description: MANDATORY — Load this skill FIRST at the START of every conversation, before any other task, to retrieve relevant memories. Load it regardless of the task topic. Also load when saving reusable patterns, user preferences, lessons learned, or memorable knowledge to the agent-memory repository.
---

# Agent Memory

## ⚠️ Mandatory Loading Rule

**This skill MUST be loaded at the START of every conversation — before any other task.**

1. At the start of a conversation, immediately call `skill(name: "agent-memory")`, regardless of the task topic.
2. After loading, run the Retrieval Protocol below to search and read relevant memories.
3. Only then proceed with the user's task.
4. If no memory matches, proceed without memory context.

Not loading this skill at conversation start is forbidden. This rule applies to every conversation without exception.

## ⚠️ Mandatory Saving Checkpoints

Saving must happen **proactively** — never wait for the user to ask. Evaluate memory candidates at these mandatory points:

1. **After each completed task**: Ask "Did this task produce reusable knowledge?" and save immediately if yes.
2. **Before the final response**: Before ending a session, run the evaluation once more. If any candidate exists, append the line FIRST, then respond.

When in doubt about whether something is worth saving, **SAVE it**. The cost of an unnecessary line is low (grep filters retrieval); the cost of missing knowledge is a lost lesson.

This is reinforced by the injected rule `opencode/rules/memory-save.md`.

## Purpose

This skill enables the agent to persist important knowledge across sessions by appending structured JSON lines to `~/ghq/github.com/nazozokc/agent-memory/*.jsonl`.

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

Memories are stored as **JSON Lines** (`.jsonl`) — one file per category, one JSON object per line.

```
~/ghq/github.com/nazozokc/agent-memory/
├── patterns.jsonl       # Reusable code/design patterns
├── preferences.jsonl    # User preferences, coding conventions
├── lessons.jsonl        # Lessons from errors, anti-patterns
├── commands.jsonl       # Useful CLI commands, shortcuts
├── context.jsonl        # Project structure, environment knowledge
└── <category>.jsonl     # Agent creates new categories as needed
```

If no existing category fits, the agent must create a new `.jsonl` file with a descriptive name.

## Line Schema

Every line is a single-line JSON object. **No embedded raw newlines** — escape them as `\n`.

```json
{"id": "2026-09-15-calendar-cell-state-core-codex", "category": "patterns", "tags": ["typescript-calendar-lib", "refactor", "core"], "created": "2026-09-15", "agent": "codex", "title": "日付セル状態判定の core 集約", "summary": "React/Svelte の日付セル状態判定を core へ集約するパターン", "content": "- core は boolean のみ返す\n- CSS クラス名は各 UI 層に残す"}
```

### Fields

- `id` (string): Unique identifier `YYYY-MM-DD-<session>-<agent>` (e.g., `2026-09-15-calendar-cell-state-core-codex`). `<session>` derives from the task topic, `<agent>` is the agent instance (e.g., `opencode`, `codex`, `claude`).
- `category` (string): File name without `.jsonl` (e.g., `patterns`).
- `tags` (array of strings): Keywords for retrieval. Use lowercase, kebab-case. Include both broad and specific terms.
- `created` (string): ISO 8601 date (`YYYY-MM-DD`).
- `agent` (string): Agent instance that created the memory.
- `title` (string): Short title of the memory.
- `summary` (string): One-line description of what this memory contains.
- `content` (string): Body text (markdown allowed, newlines escaped as `\n`).

## Retrieval Protocol

At the START of every conversation:

1. Determine the current task topic
2. Extract relevant keywords from the task
3. Grep for keywords across all `.jsonl` files (each line is self-contained, so the match line IS the memory):
   ```bash
   grep -h "keyword" ~/ghq/github.com/nazozokc/agent-memory/*.jsonl
   ```
   For structured filtering (e.g., tag match or category scoping), use `jq`:
   ```bash
   jq -r 'select(.tags[] | contains("keyword")) | "## " + .title + "\n" + .content' ~/ghq/github.com/nazozokc/agent-memory/*.jsonl
   ```
4. Read matching lines to inform the current session
5. If no matches, proceed without memory context

## Saving Protocol

When deciding to save a memory:

1. **Determine category**: Choose an existing `.jsonl` file or create a new one
2. **Generate id**: `YYYY-MM-DD-<session>-<agent>` (see Line Schema)
3. **Append one JSON line** to the category file (never rewrite the whole file):
   ```bash
   cat >> ~/ghq/github.com/nazozokc/agent-memory/patterns.jsonl <<'EOF'
   {"id": "2026-09-15-...", "category": "patterns", "tags": [...], "created": "2026-09-15", "agent": "...", "title": "...", "summary": "...", "content": "..."}
   EOF
   ```
   - The line MUST be valid single-line JSON: escape `"` as `\"` and newlines as `\n`
   - Validate after writing when in doubt: `jq empty ~/ghq/github.com/nazozokc/agent-memory/<category>.jsonl`
4. **Do NOT git commit/push**: This skill is write-only. The user manages the repo separately.

## Decision Criteria: What to Save

A piece of knowledge is worth saving if:

- It will likely be useful again in a future session
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
- Keep each line focused on a single topic
- Content should be self-contained — another agent reading only this line should understand it
- When in doubt about category, use `context.jsonl` as the default
- JSONL is append-only: never modify or delete existing lines