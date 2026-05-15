{ pkgs, ... }:

let
  Pkgs = import ./packages/wsl.nix { inherit pkgs; };
in
{
  imports = [
    ./program/gh/gh.nix
  ];

  home.packages = Pkgs;
}
