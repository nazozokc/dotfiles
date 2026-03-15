---
name: shell
description: When writing fish shell scripts, functions, abbreviations, or editing shell configuration
---

# Shell (fish) Guidelines

## When to Use

- When writing or editing fish functions under `~/.config/fish/functions/`
- When adding abbreviations (`abbr`) or aliases in `fish_user_key_bindings` or `config.fish`
- When writing fish scripts (`.fish` files)
- When debugging fish startup issues or `config.fish` errors

## Basic Rules

- **fish syntax only**: Do not use bash syntax (`[[ ]]`, `source`, `export VAR=val`, etc.)
- **No bashisms**: fish is not POSIX-compliant by design — embrace it
- **Functions over aliases**: Prefer `function` definitions over `alias` for anything non-trivial
- **Use `abbr` for short forms**: Abbreviations expand in-line and are more discoverable than aliases

## fish Syntax Cheatsheet

| Task                 | fish syntax                     | ❌ Bash (don't use)             |
| -------------------- | ------------------------------- | ------------------------------- |
| Set variable         | `set var value`                 | `var=value`                     |
| Set env variable     | `set -x VAR value`              | `export VAR=value`              |
| Local variable       | `set -l var value`              | `local var=value`               |
| Condition            | `if test $var = "foo"`          | `if [ "$var" = "foo" ]`         |
| String compare       | `if string match -q "foo" $var` | `if [[ $var == foo ]]`          |
| Command substitution | `set result (cmd)`              | `result=$(cmd)`                 |
| Source a file        | `source file.fish`              | `source file` / `. file`        |
| Append to PATH       | `fish_add_path /some/dir`       | `export PATH="$PATH:/some/dir"` |
| Return value         | `return 0`                      | same                            |
| Function args        | `$argv[1]`, `$argv`             | `$1`, `$@`                      |

## Function File Layout

```fish
# ~/.config/fish/functions/my_func.fish
function my_func --description "What this does"
    # implementation
end
```

- One function per file
- Filename must match function name exactly
- Use `--description` flag for discoverability (`functions my_func`)

## Abbreviations

```fish
# In config.fish or a dedicated file
abbr --add gs git status
abbr --add gp git push
```

- Use `abbr` for git shortcuts and common commands
- Use `--add` flag explicitly
- Keep abbreviations 2–4 chars long

## config.fish Structure

```
config.fish
├── Environment variables (set -x)
├── PATH additions (fish_add_path)
├── Abbreviations (abbr --add)
└── Source other configs if needed
```

- Do not put function definitions in `config.fish` — use `functions/` directory
- Keep `config.fish` short and readable

## Startup Performance

- Avoid heavy commands in `config.fish` (e.g. `nix` evaluations, slow `eval` calls)
- Use `fish_add_path` instead of `set -x PATH` — it deduplicates automatically
- Check startup time with: `fish --command "exit" --profile /tmp/fish-profile.txt`

## Notes

- fish config directory: `~/.config/fish/`
- Managed via dotfiles repository — edit files there, not directly in `~/.config/fish/`
- For Nix-managed fish config, changes must go through `home-manager` modules

## Related Skills

- For Nix/home-manager fish module config, see ../nix/SKILL.md
- For dotfiles file operations, see ../linux/SKILL.md

## On Rule Violations / Uncertain Cases

- If asked to write POSIX/bash syntax for a fish script, clarify that fish uses different syntax and rewrite correctly
- If unable to follow the skill's procedure, do not skip it — report to the user
