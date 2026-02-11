{ pkgs, ... }:

{
  ########################################
  # 共通CLIツール
  ########################################

  home.packages = with pkgs; [

    # 基本
    git
    curl
    wget
    neovim

    # ファイル操作・検索
    ripgrep
    fd
    eza
    bat
    fzf
    tree

    # JSON / アーカイブ
    jq
    zip
    unzip

    ########################################
    # LSP (Neovim用)
    ########################################

    lua-language-server
    nil
    pyright
    nodePackages.typescript-language-server
    nodePackages.vscode-langservers-extracted
    bash-language-server
    clang-tools
    marksman
    nixd
    pkgs.nixfmt
  ];

  ########################################
  # 共通セッション変数
  ########################################

  home.sessionVariables = {
    EDITOR = "nvim";
  };
}

