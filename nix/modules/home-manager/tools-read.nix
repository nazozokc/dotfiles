{ pkgs, ... }:

let
  Pkgs = import ../tools/packages.nix { inherit pkgs; };
in
{
  imports = [
    ../tools/program/gh/gh.nix
  ];

  home.packages = Pkgs;
}

