{ pkgs }:

with pkgs;
[
  wezterm
  audacity
  vscode
  zed
]

++ lib.optionals (stdenv.hostPlatform.system == "x86_64-linux") [
  # x86_64 only: ARM Linux builds unavailable for these packages
  ghostty
  tor-browser
  vicinae
]

++ lib.optionals stdenv.isDarwin [
  raycast
]
++ lib.optionals (stdenv.isLinux || stdenv.isDarwin) [
  spotify
  discord
  google-chrome
]
