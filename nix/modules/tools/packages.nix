{ pkgs }:

with pkgs;
[

  #Editor
  neovim # main
  vscode # GUI / debug
  zed # experimental

  #shell(main: fish)
  fish
  zsh
  bash
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

  # filer
  yazi

  # nix
  nix-tree
  direnv
  cachix
  niv

  # docker
  docker
  lazydocker

  # Languages
  python312
  nodejs_24
  bun
  deno
  rustc

  # LSP / Formatter
  rust-analyzer
  nil
  nixd
  pkgs.nixfmt
  stylua

  #package tools
  cargo
  cmake
  ninja

  #github
  bit
  git
  gh
  ghq
  lazygit
  git-wt
  gitui

  #AGENT
  kiro-cli

  #GUI software
  wezterm
  audacity
  spotify
  discord
  ghostty
  tor-browser
]
