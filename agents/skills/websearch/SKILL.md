---
name: websearch
description: Method and notes when performing web searches
---

# Web Search Guidelines

## When to Use

- When latest information is needed (package versions, release notes, etc.)
- When looking for solutions to error messages
- When referencing documentation or official sites
- When not confident in own knowledge

## Basic Rules

- **Prioritize primary sources**: Official docs, GitHub repos, and official blogs first
- **Check information freshness**: Treat old articles as reference only
- **No speculation**: If it's not in the search results, say "I don't know"
- **Verify with multiple sources**: Don't make definitive claims from a single source

## How to Form Search Queries

- **Short and specific**: Around 1–6 words
- **Search in English**: Technical queries return better results in English
- **Include version numbers**: Be specific, e.g. `neovim 0.10 treesitter`
- **Paste error messages as-is**: Don't translate error messages

## Preferred Information Sources

| Priority | Source                                         |
| -------- | ---------------------------------------------- |
| Highest  | Official documentation, official GitHub        |
| High     | Arch Wiki, NixOS Wiki                          |
| Medium   | Zenn, personal tech blogs (check date)         |
| Low      | Stack Overflow (watch for old answers), forums |

## Notes

- For Arch Linux, always refer to **Arch Wiki**
- For Nix, refer to **https://nix.dev/** and **nixpkgs GitHub**
- For npm packages, check **npmjs.com** or **GitHub**
- If nothing is found, honestly say "I couldn't find it"
- Honesty is everything.

## On Rule Violations / Uncertain Cases

- If asked to perform a forbidden operation, do not execute it — explain the reason and confirm with the user
- If unable to follow the skill's procedure (e.g. command not found), do not skip it — report to the user
