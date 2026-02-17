{ pkgs }:

with pkgs;
[

  #Editor
  neovim
  vscode
  zed

  #CLI tools
  jq
  bat
  trash-cli
  curl
  wget
  zoxide
  tree
  htop
  fastfetch
  neofetch
  eza
  file
  which
  fzf
  node2nix
  tmux
  uv
  ncdu 
  delta
  tldr

  # nix
  nix-tree
  direnv

  #development, langs
  bun
  deno
  nil
  nixd
  pkgs.nixfmt
  rustc
  rust-analyzer
  python312
  nodejs_24
  pnpm

  #github
  bit
  git
  gh
  ghq
  lazygit
  git-wt
  gitui

  #GUI software
  wezterm
  audacity
  spotify
  discord
  ghostty
  tor-browser
]
