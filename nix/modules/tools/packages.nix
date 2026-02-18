{ pkgs }:

with pkgs;
[

  #Editor
  neovim
  vscode
  zed

  #shell
  fish
  zsh
  starship

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
  onefetch
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
  bottom
  just
  xh

  # nix
  nix-tree
  direnv
  cachix
  niv

  # docker
  docker
  lazydocker

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

  #package tools
  cargo

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
