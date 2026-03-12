{ pkgs }:

with pkgs;
[
  wezterm
  audacity
  obsidian
  raycast
]
++ lib.optionals (pkgs.stdenv.hostPlatform.system == "x86_64-linux") [
  ghostty
  tor-browser
  spotify
  discord
  google-chrome
]
++ lib.optionals pkgs.stdenv.isDarwin [
  spotify
  discord
  google-chrome
]
