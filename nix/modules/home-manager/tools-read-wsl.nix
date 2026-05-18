{ pkgs, ... }:

let
  Pkgs = import ./packages/wsl.nix { inherit pkgs; };
in
{
  imports = [
    ./programs-common.nix
  ];

  home.packages = Pkgs;
}
