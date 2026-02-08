{ pkgs }:

with pkgs; [
  # terminal / shell
  neovim
  wezterm
  ghostty
  fish

  # IME
  fcitx5
  fcitx5-mozc
  qt6Packages.fcitx5-configtool

  # GUI apps (unfree)
  google-chrome
  discord
  spotify

  # tools
  git
  gh
  curl
  wget

  # node ecosystem
  nodejs
  nodePackages.pnpm
]

