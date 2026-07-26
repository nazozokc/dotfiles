{ pkgs }:

with pkgs;
[
  audacity
  vscode
  zed
]

++ lib.optionals (stdenv.hostPlatform.system == "x86_64-linux") [
  # x86_64 only: ARM Linux builds unavailable for these packages
  # ghostty は linux/default.nix で nixGL ラップしてインストール
  tor-browser
]

++ lib.optionals stdenv.isDarwin [
  raycast
]
++ lib.optionals (stdenv.hostPlatform.system == "x86_64-linux" || stdenv.isDarwin) [
  spotify
  discord
  google-chrome
]
