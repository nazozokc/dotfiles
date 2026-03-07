{ pkgs }:

with pkgs;
[
  # GUI software
  wezterm
  audacity
  spotify
  discord
  google-chrome
  tor-browser
  obsidian
]
++ lib.optionals pkgs.stdenv.isLinux [
  ghostty
]
