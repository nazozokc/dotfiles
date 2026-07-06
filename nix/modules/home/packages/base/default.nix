{ pkgs }:

with pkgs;
[
  # shell
  fish
  zsh

  # CLI tools
  jq
  curl
  wget
  zoxide
  tree
  btop
  fastfetch
  onefetch
  eza
  which
  tmux
  uv
  ncdu
  tldr
  pet
  just

  # filer
  yazi

  # nix
  nix-tree
  cachix
  niv
  nix-output-monitor

  # docker
  docker
  lazydocker

  # github
  gh
  ghq
  git-wt
  jujutsu
  gitui
  git-secrets
  tig
  ghgrab

  # util
  presenterm
  trash-cli

  # other
  rename
  inetutils
  lsof
  comma
  aria2
  mise
  cmake
]
