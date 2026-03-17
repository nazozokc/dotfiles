---
name: typescript
description: Guidelines when working on TypeScript/JS projects
---

# TypeScript Development Guidelines

## Basic Principles

- **Type safety first**: Avoid `any` — define types explicitly
- **Never leave errors**: Address all TypeScript errors immediately
- **Strict mode**: Use strict type checking whenever possible

## Coding Conventions

- Prefer explicit type declarations over relying on inference
- Use `@types/*` packages for third-party type definitions
- Use `typeof` or type guards for `unknown` types
- Express optional properties with `?`

## Error Handling Priority

1. Fix type errors on the spot
2. Resolve warnings whenever possible
3. If a warning must remain, document the reason in a comment

## Lint / Format

- If `biome.json` exists at project root, use `biome check`
- Otherwise use `eslint . --ext .ts`
- If neither exists, ask the user

## What to Verify

- Confirm no errors with `tsc --noEmit`
- Check the project's lint rules before starting

## On Rule Violations / Uncertain Cases

- If asked to perform a forbidden operation, do not execute it — explain the reason and confirm with the user
- If unable to follow the skill's procedure (e.g. command not found), do not skip it — report to the user
