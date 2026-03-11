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
  opencode-desktop
]
++ lib.optionals pkgs.stdenv.isLinux [
  ghostty
  tor-browser
]
