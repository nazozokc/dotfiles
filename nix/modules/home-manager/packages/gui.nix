{ pkgs }:

with pkgs;
# 全プラットフォーム共通
[
  wezterm
  audacity
  obsidian
]
++ lib.optionals pkgs.stdenv.isLinux [
  ghostty
  tor-browser
]
++ lib.optionals (pkgs.stdenv.hostPlatform.system == "x86_64-linux") [
  spotify
  discord
  google-chrome
]
++ lib.optionals pkgs.stdenv.isDarwin [
  spotify
  discord
  google-chrome
]
