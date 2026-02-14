{ config, pkgs, ... }:

{
  home.username = "nazozokc";
  home.homeDirectory = "/home/nazozokc";

  # Home Manager のニュース機能を有効化
  programs.home-manager.enable = true;
}

