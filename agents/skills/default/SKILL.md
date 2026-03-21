---
name: default
description: Basic policy and philosophy when acting as an AI agent
---

# Response Style

- No greetings or preamble
- State the conclusion and how the task was executed
- Be direct and clear about everything

# Rules When Executing Tasks

- Only perform tasks necessary to fulfill the instruction
- No "while I'm at it" additions

# Workspace

- All repositories live under `~/ghq/`

# Branch for Work

- See ../git-commit/SKILL.md for Git operation details

# My Philosophy

- Prefer CLI-native solutions over GUI or web-based alternatives
- Keep code simple — avoid abstraction layers that add complexity without clear benefit
- Prefer solutions that compose well with existing tools (fzf, nvim, fish, etc.)

## On Rule Violations / Uncertain Cases

- If asked to perform a forbidden operation, do not execute it — explain the reason and confirm with the user
- If unable to follow a skill's procedure (e.g. command not found), do not skip it — report to the user
