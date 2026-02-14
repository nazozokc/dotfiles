{ pkgs, ... }:

{
  home.packages =
    let
      cliPkgs = import ../defaults/cli-default.nix { inherit pkgs; };
      guiPkgs = import ../defaults/gui-default.nix { inherit pkgs; };
      langPkgs = import ../defaults/lang-default.nix { inherit pkgs; };
    in
    cliPkgs ++ guiPkgs ++ langPkgs;
}
