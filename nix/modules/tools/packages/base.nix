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
  btop
  fastfetch
  onefetch
  eza
  which
  fzf
  tmux
  uv
  ncdu
  delta
  tldr
  pet
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
  jujutsu
  gitui
  git-secrets
  tig

  #util
  presenterm

  #other
  rename
  inetutils
  comma
]
