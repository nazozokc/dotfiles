{ pkgs, ... }:

let
  Pkgs = import ./packages { inherit pkgs; };
in
{
  imports = [
    ./tools/program/gh/gh.nix
  ];

  home.packages = Pkgs;
}
