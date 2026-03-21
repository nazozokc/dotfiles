---
name: nix
description: Guidelines when managing Nix configuration
---

# Nix Operation Guidelines

## Home-Manager Module Pattern

```nix
# Standard module structure used in this repo
{ config, pkgs, ... }: {
  programs.<name> = {
    enable = true;
    # options...
  };
}
```

**Always verify with `home-manager switch --flake .#<host>` after changes.**

## Adding a New Package

```bash
# 1. Add to home.packages or the appropriate programs.<name> block
# 2. Run:
home-manager switch --flake .#<host>
# 3. Verify the binary is available:
which <package>
```

## Common Pitfalls

- Do not use `with pkgs;` at the top level — it pollutes scope and makes deps unclear
- Avoid `pkgs.writeShellScriptBin` for complex scripts — use a dedicated derivation instead
- If a build fails with 'untrusted substituter', check `nix.conf` or pass `--accept-flake-config`

## flake.lock Update Procedure

```bash
# 1. Run update (only if this command is defined in the flake)
nix run .#update

# 2. Stage changes
git add .

# 3. Commit (English only)
<type>: <summary>

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
