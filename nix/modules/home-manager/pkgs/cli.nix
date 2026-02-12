{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # 基本
    git
    curl
    wget
    lazygit
    # 開発・操作系
    neovim
    ripgrep
    fd
    bat
    eza
    jq
    tree
    # Nix 補助
    nix-output-monitor
  ];
}

