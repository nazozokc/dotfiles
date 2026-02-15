{ pkgs, ... }:

{
  home.packages =
    let
      Pkgs = import ../tools/packages.nix { inherit pkgs; };
    in
    Pkgs;
}
