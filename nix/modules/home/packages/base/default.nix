{ pkgs }:

with pkgs;
[
  # shell
  nushell
  zsh

  # CLI tools
  jq
  curl
  wget
  zoxide
  fd
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
  dig

  # filer
  yazi

  # nix
  nix-tree
  cachix
  niv
  nix-output-monitor
  nh

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
  bitwarden-cli
  bitwarden-desktop
  _1password-cli

  # mail
  aerc
  neomutt
  himalaya
]
