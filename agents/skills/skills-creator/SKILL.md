---
name: skills-creator
description: Template and notes when creating or updating SKILL.md files under skills/
---

# Skill Creation Guidelines

## When to Use

- When creating a new `skills/*/SKILL.md`
- When improving or updating an existing skill

## Basic SKILL.md Structure
```markdown
---
name: <skill name (match directory name)>
description: <one-line summary of when and why to use it>
---

# <Title>

## When to Use

- ...

## Basic Rules

- ...

## Notes

- ...
```

## Writing Rules

- **Write in English**: All skills in this dotfiles repo use English
- **Use bullet points**: No long prose — keep it concise
- **Always write "When to Use"**: Critical for agents to determine trigger conditions
- **Be explicit about prohibitions**: Clearly state "don't do X" or "X is forbidden"
- **Include examples**: Commands and formats should have concrete examples

## What Not to Do

- Leave `description` empty (skill will never be triggered)
- Use vague expressions ("might", "depending on the case")
- Pack multiple roles into one skill
- Duplicate content from other skills (use `see ../other/SKILL.md` instead)

## How to Write description

### Good Examples

- `When performing Git commits and pushes`
- `When creating a PR with gh cli`
- `When generating Nix code, editing flakes, or operating home-manager`

### Bad Examples

- `git stuff` (too abstract)
- `information about commits` (not a conditional statement)

## Registering in CLAUDE.md

After creating a new skill, add an entry to `agents/CLAUDE.md`:
```markdown
## ./skills/<name>/SKILL.md

Always refer to this skill when <use case>.
```

## File Layout
```
skills/
└── <name>/
    └── SKILL.md   ← This is all you need (keep it simple)
```

## On Rule Violations / Uncertain Cases

- If asked to perform a forbidden operation, do not execute it — explain the reason and confirm with the user
- If unable to follow the skill's procedure (e.g. command not found), do not skip it — report to the user
