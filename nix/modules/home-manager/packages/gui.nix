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
  # spotify, discord, google-chrome are only on x86_64-linux
]
++ lib.optionals pkgs.stdenv.isDarwin [
  raycast
  # spotify, discord, google-chrome are only on macOS
]
++ lib.optionals (pkgs.stdenv.hostPlatform.system != "aarch64-darwin") [
  # Apple Silicon macOS has different package availability
  spotify
  discord
  google-chrome
]
