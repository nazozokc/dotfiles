# nix/modules/home-manager/packages/gui.nix
{ pkgs }:

with pkgs;
[
  wezterm
  audacity
  discord
  google-chrome
  obsidian
]
++ lib.optionals pkgs.stdenv.isLinux [
  ghostty
  tor-browser
]
++ lib.optionals (pkgs.stdenv.isLinux && pkgs.stdenv.hostPlatform.system == "x86_64-linux") [
  spotify # x86_64-linux のみ
]
++ lib.optionals pkgs.stdenv.isDarwin [
  spotify # aarch64-darwin は対応してる
]
