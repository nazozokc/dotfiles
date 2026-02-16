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
  eza
  file
  which
  fzf
  node2nix
  tmux
  uv

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
  npm
  pnpm

  #github
  bit
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
