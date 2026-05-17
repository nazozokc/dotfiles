{ pkgs }:
with pkgs;
[
  wezterm
  audacity
  vscode
  zed
]
++ pkgs.lib.optionals (pkgs.stdenv.hostPlatform.system == "x86_64-linux") [
  ghostty
  tor-browser
  vicinae
]
++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
  raycast
]
++ pkgs.lib.optionals (pkgs.stdenv.hostPlatform.system == "x86_64-linux" || pkgs.stdenv.isDarwin) [
  spotify
  discord
  google-chrome
]
