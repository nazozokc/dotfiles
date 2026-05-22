{ pkgs, ... }:

let
  inherit (pkgs.lib) flatten;
in
{
  home.packages = flatten [
    (import ./base { inherit pkgs; })
    (import ./dev { inherit pkgs; })
    (import ./ai { inherit pkgs; })
    (import ./gui { inherit pkgs; })
    (import ./experimental { inherit pkgs; })
  ];
}
