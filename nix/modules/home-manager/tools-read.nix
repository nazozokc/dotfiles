{ pkgs, ... }:

let
  Pkgs = import ./packages { inherit pkgs; };
in
{
  imports = [
    ./programs-common.nix
  ];

  home.packages = Pkgs;
}
