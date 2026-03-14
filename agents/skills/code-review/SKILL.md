---
name: code-review
description: Perspectives and rules when conducting a code review
---

# Code Review Guidelines

## Related Skills
- For PR creation guidelines, see ../create-pr/SKILL.md
- For Git commit guidelines, see ../git-commit/SKILL.md

## Review Perspectives (by priority)

### 1. Security

- No hardcoded secrets (API keys, passwords)
- No risk of injection attacks
- No excessive permission grants

### 2. Performance

- No unnecessary loops or recursion
- No risk of memory leaks
- Proper handling of async operations

### 3. Maintainability

- No code duplication
- Are names clear and meaningful?
- No over-commenting or under-commenting
- Is function/component granularity appropriate?

### 4. Pattern Consistency

- Matches existing code style
- Follows project-specific conventions
- Tests are appropriate
- No duplicate roles

## Review Mindset

- **Be respectful**: Use suggestion form, not imperative form
- **Explain why**: Reasoning makes feedback easier to accept
- **Big picture**: Prioritize consistency over personal preference

## On Rule Violations / Uncertain Cases

- If asked to perform a forbidden operation, do not execute it — explain the reason and confirm with the user
- If unable to follow the skill's procedure (e.g. command not found), do not skip it — report to the user
