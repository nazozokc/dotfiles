{ pkgs, ... }:

{
  home.packages =
    let
      cliPkgs = import ../pkgs/cli/default.nix { inherit pkgs; };
      guiPkgs = import ../pkgs/gui/default.nix { inherit pkgs; };
      langPkgs = import ../pkgs/lang/default.nix { inherit pkgs; };
    in
    cliPkgs ++ guiPkgs ++ langPkgs;
}
