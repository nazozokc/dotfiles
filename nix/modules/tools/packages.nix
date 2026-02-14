{ pkgs }:

with pkgs; [

  #Editor
  neovim
  vscode
  zed

  #CLI tools
  coreutils
  bun
  jq
  curl
  wget
  zoxide
  tree
  htop
  file
  which
  fzf
  node2nix
  
  #github
  git
  gh
  ghq
  lazygit
  git-wt

  #GUI software
  wezterm
  spotify
  discord
  ghostty
]
