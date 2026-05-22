{ pkgs }:
# WSL packages: same as default but without GUI apps
let
  inherit (pkgs.lib) flatten;
in
flatten [
  (import ./base { inherit pkgs; })
  (import ./dev { inherit pkgs; })
  (import ./ai { inherit pkgs; })
  (import ./experimental { inherit pkgs; })
]
