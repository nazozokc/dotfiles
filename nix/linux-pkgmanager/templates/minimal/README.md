# linux-pkgmanager.nix minimal template

```bash
nix flake init -t github:nazozokc/linux-pkgmanager.nix#minimal
nix run .#nlp-diff
nix run .#nlp-apply
nix run .#nlp-update
```

This template uses `autoDetect = true` so it works across apt/pacman/dnf without changes.
