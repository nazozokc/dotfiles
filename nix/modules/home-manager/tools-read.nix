{ pkgs, ... }:

{
  home.packages =
    let
      Pkgs = import ../tools/packages.nix { inherit pkgs; };
      gh = import ../tools/program/gh.nix { inherit pkgs; };
    in
    Pkgs ++ gh;
}
