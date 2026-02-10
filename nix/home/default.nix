{ config, pkgs, ... }:

{
  home.username = "nazozokc";
  home.homeDirectory = "/home/nazozokc";
  home.stateVersion = "24.11";

  imports = [
    ./fish.nix
  ];

  programs.git = {
    enable = true;
    settings.user = {
      name = "nazozokc";
      email = "nazozokc@gmail.com";
    };
  };
}

