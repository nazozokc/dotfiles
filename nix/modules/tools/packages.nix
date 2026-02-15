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
  file
  which
  fzf
  node2nix

  #development, langs
  bun
  deno
  nil
  nixd
  pkgs.nixfmt
  rustc
  rust-analyzer
  python312

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
