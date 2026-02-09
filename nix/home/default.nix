{ config, pkgs, ... }:

{
  home.username = "nazozokc";
  home.homeDirectory = "/home/nazozokc";

  home.stateVersion = "24.05";

  imports = [
    ./fish.nix
    ./git.nix
    ./direnv.nix
  ];

  programs.home-manager.enable = true;
}

