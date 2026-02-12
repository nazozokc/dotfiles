{ config, pkgs, inputs, lib, ... }:

{
  home.packages = with pkgs; [
    discord
    spotify
    vscode
    google-chrome
    firefox
    wezterm
    ghostty
    ];
}
