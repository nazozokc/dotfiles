{ pkgs }:

with pkgs; [

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
  file
  which
  fzf
  node2nix

  #development, langs
  nodejs_24
  bun
  deno
  nodePackages.npm
  nodePackages.pnpm
  nil
  nixd
  nixPkgs.nixfmt
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
