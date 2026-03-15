---
name: cli
description: When creating Node.js/TypeScript CLI tools
---

# CLI Tool Development Guidelines

## When to Use

- When building command-line tools in TypeScript/Node.js
- When setting up CLI scaffolding with commander/yargs
- When adding CLI-specific features (completion, prompts, error handling)

## Basic Rules

- **Use commander or yargs**: Prefer `commander` for simple CLIs, `yargs` for complex ones
- **TypeScript first**: Always use TypeScript with strict mode
- **Exit codes**: Use proper exit codes (0 for success, 1 for errors, 2 for invalid args)
- **No interactive by default**: CLI tools should be non-interactive unless explicitly requested

## User Experience

- **Clear error messages**: Show helpful error messages with actionable solutions
- **Progress indicators**: Use `ora` or `listr` for long-running operations
- **Interactive prompts**: Use `inquirer` or `enquirer` when user input is required
- **Color output**: Use `chalk` or `kleur` for meaningful color coding
- **Verbose mode**: Support `--verbose` flag for detailed logging

## Build & Deployment

- **Bin field**: Set `bin` field in package.json for CLI entry point
- ** shebang**: Use `#!/usr/bin/env node` in entry file
- **ESM support**: Include `"type": "module"` for ESM support
- **Cross-platform**: Avoid platform-specific commands unless necessary
- **Version bumping**: Use `version` command or automated versioning

## File Structure

```
cli/
├── src/
│   ├── index.ts      # Entry point
│   ├── commands/     # Command definitions
│   ├── utils/        # Helper functions
│   └── types.ts      # Shared types
├── package.json
└── README.md
```

## Commands to Verify

- Run `tsc --noEmit` to check types
- Run `npm run build` before publishing
- Test with `npm link` locally

## Related Skills

- For general code generation, see ../code-gen/SKILL.md
- For TypeScript rules, see ../typescript/SKILL.md
- For Nix packaging, see ../nix/SKILL.md

## On Rule Violations / Uncertain Cases

- If asked to perform a forbidden operation, do not execute it — explain the reason and confirm with the user
- If unable to follow the skill's procedure, do not skip it — report to the user
