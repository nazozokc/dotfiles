---
name: nix-flake-make
description: When creating flake.nix for project-level development environments or shared devShells
---

# Nix Flake Development Environment

## When to Use

- Creating a new `flake.nix` in a project directory
- Adding or editing `devShells` for a repository
- Setting up `.envrc` for direnv integration
- Making a Nix-based reproducible dev environment for any project

## Basic Rules

- **Always use `flake-parts`** for multi-output flakes (when there are 3+ outputs)
- **Always set `systems`** explicitly — do not rely on default
- **Always use `nixpkgs` unstable** unless there's a specific reason not to
- **Pin inputs with `follows`** to reduce duplicates and download sizes
- **Keep it minimal** — only include what the project actually needs

## Minimal flake.nix Template

```nix
{
  description = "project dev environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];

      perSystem = { system, ... }:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          devShells.default = pkgs.mkShell {
            name = "my-project";
            packages = with pkgs; [
              # add tools here
            ];
            shellHook = ''
              echo "[devShell:default]"
              # verify tools here
            '';
          };
        };
    };
}
```

## Per-Language Patterns

### TypeScript / Node.js

```nix
packages = with pkgs; [
  nodejs_24
  corepack_24
  pnpm   # if using pnpm
];
shellHook = ''
  echo "[devShell:ts] node $(node --version) | pnpm $(pnpm --version)"
'';
```

### Rust

```nix
packages = with pkgs; [
  cargo
  rustc
  rust-analyzer
  clippy
  rustfmt
];
shellHook = ''
  echo "[devShell:rust] cargo $(cargo --version)"
'';
```

### Go

```nix
packages = with pkgs; [
  go
  golangci-lint
  gopls
];
```

### Python

```nix
packages = with pkgs; [
  (python3.withPackages (ps: with ps; [
    # add packages here
  ]))
  ruff
  pyright
];
```

## direnv Integration

Create `.envrc` in the project root:

```bash
use flake
```

Then run:

```bash
direnv allow
```

**Never commit `.direnv/`** — add it to `.gitignore`.

## nixConfig (Binary Cache)

Use this for projects with heavy builds (Rust, large C deps):

```nix
nixConfig = {
  extra-substituters = [
    "https://cache.nixos.org/"
    "https://cache.numtide.com"
  ];
  extra-trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "cache.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
  ];
};
```

## Common Pitfalls

- **Do not use `with pkgs;`** at the top level of `packages` — it pollutes scope
- **Do not hardcode system** — always derive from `system` parameter via `perSystem`
- **Do not put `shellHook` in `mkShell` after `packages`** — order matters for readability: name, packages, shellHook
- **Do not forget `flake.lock`** — commit it for reproducibility
- **Do not use `mkShell` for builds** — use `mkDerivation` for derivations

## Verification

After creating or editing:

```bash
# Check flake evaluates correctly
nix flake check

# Enter the dev shell
nix develop

# If using direnv
direnv allow
```

## Notes

- This skill is for **project-level** dev environments, not for dotfiles/home-manager
- For home-manager or dotfiles flake changes, see `../nix/SKILL.md`
- `shellHook` is for printing info only — keep it lightweight
- Prefer `pkgs.mkShell` over `pkgs.mkShellNoCC` only when C compiler is needed
