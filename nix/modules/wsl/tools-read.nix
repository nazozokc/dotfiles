{ pkgs, ... }:

let
  Pkgs = import ../home/packages/wsl.nix { inherit pkgs; };
in
{
  imports = [
    ../home/programs-common.nix
  ];

  home.packages = Pkgs;
}
