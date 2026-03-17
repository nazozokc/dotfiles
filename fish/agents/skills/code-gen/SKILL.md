---
name: code-gen
description: When generating or writing code in any language
---

# Code Generation Guidelines

## When to Use

- When writing new functions, classes, or modules
- When generating boilerplate or scaffolding code
- When implementing logic from a specification or description

## Basic Rules

- **Ask before assuming**: If requirements are ambiguous or incomplete, ask the user before writing code
- **Language-agnostic**: These rules apply to all languages unless a language-specific skill overrides them
- **No placeholder logic**: Never write `// TODO: implement this` — either implement it or ask

## Error Handling

- Always handle errors explicitly — never silently swallow them
- Use language-appropriate patterns (e.g. `try/catch`, `Result`, `Option`, error return values)
- Propagate errors to the caller unless there's a clear reason to handle locally
- Never use empty catch blocks without a comment explaining why

## Comments and Documentation

- Write a doc comment for every public function/method (purpose, params, return value)
- Inline comments for non-obvious logic only — don't comment the obvious
- Keep comments up-to-date with the code — outdated comments are worse than none

## When Something Is Unclear

- If the spec is incomplete, ask the user for clarification before writing
- If multiple valid approaches exist, present the options with tradeoffs and ask
- Never invent requirements — if it wasn't asked for, don't add it

## Related Skills

- For TypeScript-specific rules, see ../typescript/SKILL.md
- For Nix-specific rules, see ../nix/SKILL.md
- For Neovim Lua config, see ../neovim/SKILL.md

## On Rule Violations / Uncertain Cases

- If asked to perform a forbidden operation, do not execute it — explain the reason and confirm with the user
- If unable to follow the skill's procedure, do not skip it — report to the user
