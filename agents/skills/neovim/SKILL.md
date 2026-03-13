---
name: neovim
description: When editing Neovim config, adding plugins, or optimizing startup time
---

# Neovim Configuration Guidelines

## When to Use

- When adding or removing plugins with `lazy.nvim`
- When optimizing startup time
- When changing LSP, DAP, or formatter configuration

## Basic Rules

- **Config lives under `~/.config/nvim/`**: Managed via dotfiles repository
- **Be conscious of lazy.nvim event specification**: Directly affects startup speed
- **No duplicate configs**: Before adding a plugin, confirm nothing already fills that role

## Plugin Addition Checklist

1. Check if a plugin with the same role already exists (e.g. formatters are unified under conform.nvim)
2. Consider whether lazy loading via `event` / `ft` / `cmd` is possible
3. Visual plugins should use `event = "VeryLazy"`
4. After adding, verify startup time with `--startuptime`

## lazy.nvim Event Guide

| Event         | Use Case                 |
| ------------- | ------------------------ |
| `VeryLazy`    | Colorschemes, UI plugins |
| `BufReadPre`  | File reading plugins     |
| `InsertEnter` | Completion, snippets     |
| `LspAttach`   | LSP-dependent plugins    |
| `cmd`         | Command-triggered only   |

## Notes

- Never call `require()` outside of `config` (it loads at startup)
- DAP and git plugins are especially prone to duplication — check carefully

## On Rule Violations / Uncertain Cases

- If asked to perform a forbidden operation, do not execute it — explain the reason and confirm with the user
- If unable to follow the skill's procedure (e.g. command not found), do not skip it — report to the user
