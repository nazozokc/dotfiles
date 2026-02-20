{ pkgs }:

with pkgs;
[
  # Editor
  neovim
  vscode
  zed

  # shell
  fish
  zsh
  bash
  starship

  # CLI tools
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

  # github
  bit
  git
  gh
  ghq
  lazygit
  git-wt
  gitui
  git-secrets
  tig

  # AGENT
  kiro-cli

  #other
  translate-cli
  rename
]
