{ pkgs }:
# WSL packages: same as default but without GUI apps
let
  inherit (pkgs.lib) flatten;
in
flatten [
  (import ./base.nix { inherit pkgs; })
  (import ./dev.nix { inherit pkgs; })
  (import ./cli.nix { inherit pkgs; })
]
