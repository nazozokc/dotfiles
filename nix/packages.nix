{ pkgs }:

with pkgs; [
# terminal
  neovim
  wezterm
  ghostty
  fish

# 文字入力
  fcitx5
  fcitx5-mozc
  qt6Packages.fcitx5-configtool
  discord
  spotify
  google-chrome

# ソフトインストール,github-cli
gh
  git
  curl
  wget
]

