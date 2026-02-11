{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    git
    curl
    wget
    ripgrep
    gh
    fd
    bat
    neovim
    eza
    fzf
    jq
    tree
    zip
    unzip

    # LSP
    lua-language-server
    pyright
    nodePackages.typescript-language-server
    nodePackages.vscode-langservers-extracted
    bash-language-server
    clang-tools
    marksman
    nixd
    pkgs.nixfmt
  ];
}

