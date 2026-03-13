---
name: nix
description: Guidelines when managing Nix configuration
---

# Nix Operation Guidelines

## flake.lock Update Procedure
```bash
# 1. Run update (only if this command is defined in the flake)
nix run .#update

# 2. Stage changes
git add .

# 3. Commit (English only)
git commit -m "update flake.lock:YYYYMMDD"

# 4. Push to remote
git push
```

## Alternative (if nix run is not defined)
```bash
nix flake update
```

## Build Verification
```bash
# nixpkgs overlay etc.
nix build .#<target>

# For home-manager (replace host with config name)
home-manager switch --flake .#<host>
```

## Principles When Changing Code

- **Respect the design**: Honor the existing Nix structure
- **Self-review**: Never over-trust your own code — verify thoroughly
- **Simplicity**: Prioritize readable code over complexity
- **Reference**: When in doubt, refer to https://nix.dev/

## Notes

- Nix is declarative config management — be careful with side-effectful operations
- Keep patches and overlays to a minimum

## On Rule Violations / Uncertain Cases

- If asked to perform a forbidden operation, do not execute it — explain the reason and confirm with the user
- If unable to follow the skill's procedure (e.g. command not found), do not skip it — report to the user
