{ pkgs }:

with pkgs;
[
  # Editor
  neovim

  # shell
  fish
  zsh
  # starship -> managed by programs.starship

  # CLI tools
  jq
  # bat -> managed by programs.bat
  curl
  wget
  zoxide
  tree
  btop
  fastfetch
  onefetch
  eza
  which
  # fzf -> managed by programs.fzf
  tmux
  uv
  ncdu
  # delta -> managed by programs.delta
  tldr
  pet
  just

  # filer
  yazi

  # nix
  nix-tree
  # direnv -> managed by programs.direnv
  cachix
  niv

  # docker
  docker
  lazydocker

  # github
  # git -> managed by programs.git
  gh
  ghq
  # lazygit -> managed by programs.lazygit
  git-wt
  jujutsu
  gitui
  git-secrets
  tig

  # util
  presenterm
  trash-cli

  # other
  rename
  inetutils
  comma
]
