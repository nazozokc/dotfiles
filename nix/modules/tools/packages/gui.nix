{ pkgs }:

with pkgs;
[
  # GUI software
  wezterm
  audacity
  spotify
  discord
  google-chrome
  obsidian
]
++ lib.optionals pkgs.stdenv.isLinux [
  ghostty
  tor-browser
]
