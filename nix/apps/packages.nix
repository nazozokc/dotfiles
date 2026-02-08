{ pkgs }:

with pkgs; [
  # terminal
  neovim
  wezterm
  ghostty
  fish
  kanata
  opencode

  # 文字入力
  fcitx5
  fcitx5-mozc
  qt6Packages.fcitx5-configtool

  # アプリ
  discord
  spotify
  google-chrome

  # 基本ツール
  curl
  gh
  ghq
  git
  wget

  # 1password
  _1password-cli
  _1password-gui
]

