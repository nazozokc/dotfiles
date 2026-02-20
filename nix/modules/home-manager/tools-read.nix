{ pkgs, nodePackages, ... }:

let
  Pkgs = import ../tools/packages { inherit pkgs; };
in
{
  imports = [
    ../tools/program/gh/gh.nix
  ];

  home.packages = Pkgs;
}
