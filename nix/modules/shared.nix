{ pkgs, system, username, ... }:

{
  home.username = username;

  home.homeDirectory =
    if pkgs.stdenv.isDarwin
    then "/Users/${username}"
    else "/home/${username}";

  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  imports = [
    ../config-sym.nix
    ./pkgs/cli.nix
    ./pkgs/gui.nix

    (if pkgs.stdenv.isLinux
     then ./os/linux.nix
     else ./os/darwin.nix)
  ];
}

