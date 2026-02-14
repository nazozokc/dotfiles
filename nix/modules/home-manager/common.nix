{ pkgs, ... }:

{
  home.packages =
    let
      Pkgs = import ../tools/packages.nix { inherit pkgs; };
      langPkgs = import ../tools/lang-pkgs.nix { inherit pkgs; };
      nodePkgs = import ../tools/node-pkgs.nix { inherit pkgs; };
    in
    Pkgs ++ langPkgs ++ nodePkgs;
}
