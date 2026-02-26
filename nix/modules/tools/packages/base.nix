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
  onefetch
  eza
  which
  fzf
  tmux
  cmux
  uv
  ncdu
  delta
  tldr
  bottom
  just

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
  gibo

  #util
  presenterm

  #other
  rename
  inetutils
]
