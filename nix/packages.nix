{ pkgs }:

with pkgs; [
  # terminal
  neovim
  wezterm
  ghostty
  fish

  # IME
  fcitx5
  fcitx5-mozc
  qt6Packages.fcitx5-configtool

  # apps
  discord
  spotify
  google-chrome

  # tools
  curl
  wget
  git
  gh

  # node
  nodejs
  nodePackages.pnpm
]

