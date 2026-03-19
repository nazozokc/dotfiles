{ pkgs }:
with pkgs;
[
  wezterm
  audacity
  obsidian
]
++ lib.optionals (pkgs.stdenv.hostPlatform.system == "x86_64-linux") [
  ghostty
  tor-browser
  vicinae
  kdePackages.partitionmanager
]
++ lib.optionals pkgs.stdenv.isDarwin [
  raycast
]
++ lib.optionals (pkgs.stdenv.hostPlatform.system == "x86_64-linux" || pkgs.stdenv.isDarwin) [
  spotify
  discord
  google-chrome
]
