{ pkgs, ... }:

let
  inherit (pkgs.lib) flatten;
in
{
  home.packages = flatten [
    (import ./base.nix { inherit pkgs; })
    (import ./dev.nix { inherit pkgs; })
    (import ./cli.nix { inherit pkgs; })
    (import ./gui.nix { inherit pkgs; })
  ];
}
