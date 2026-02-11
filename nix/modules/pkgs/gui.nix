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
    zen-browser   # ここで inputs を使う場合も可能
  ];
}

