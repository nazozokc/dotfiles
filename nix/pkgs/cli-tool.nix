{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # 基本
    git
    gh
    curl
    wget

    # 便利CLI
    ripgrep   # rg
    fd        # fd
    bat       # cat代替
    eza       # ls代替
    fzf       # fuzzy finder
    neovim
    fish

    # アーカイブ/検索
    unzip
    zip
    jq
    tree

    # ネットワーク/デバッグ
    httpie
    tcpdump
  ];
}

