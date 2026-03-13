---
name: arch-linux
description: Constraints when operating files in an Arch Linux environment
---

# Arch Linux File Operation Guidelines

## Forbidden Areas (Absolutely Prohibited)

- System configuration under `/etc/`
- System files under `/usr/`
- Variable data under `/var/`
- Any operation requiring `sudo`
- Direct editing of system packages

## Allowed Areas

- User configuration under `~/.config/`
- Personal files under `~/` (home directory)
- Files within this repository (dotfiles)

## Principles When Operating

- **Only do what's instructed**: Execute only what the user explicitly requested
- **No "while I'm at it"**: Never perform related work without being asked
- **Confirm first**: Report potentially dangerous operations before executing
- **Backup**: Save the current state before making significant changes

## Key Decision Criteria

"Is this a system config?" → If unsure, don't touch it
"Is this a personal config?" → OK if it's within dotfiles

## On Rule Violations / Uncertain Cases

- If asked to perform a forbidden operation, do not execute it — explain the reason and confirm with the user
- If unable to follow the skill's procedure (e.g. command not found), do not skip it — report to the user
