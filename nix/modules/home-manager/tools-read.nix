{ pkgs, ... }:

let
  Pkgs = import ../tools/packages.nix { inherit pkgs; };
in
{
  imports = [
    ../tools/program/gh/gh.nix
    ../tools/program/gh/gh-brag.nix
  ];

  home.packages = Pkgs;
}

