{ pkgs, ... }:

let
  Pkgs = import ./packages { inherit pkgs; };
in
{
  imports = [
    ./program/gh/gh.nix
  ];

  home.packages = Pkgs;
}
