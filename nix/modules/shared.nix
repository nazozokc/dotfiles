{ config, pkgs, username, systemType, ... }:

{
  home.username = username;

  home.homeDirectory =
    if systemType == "darwin"
    then "/Users/${username}"
    else "/home/${username}";

  home.stateVersion = "23.11";

  imports = [
    ./pkgs/cli.nix
    ./pkgs/gui.nix
  ];

  programs.home-manager.enable = true;
}

