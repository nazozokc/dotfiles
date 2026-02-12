{ config, pkgs, lib, username, system, ... }:

{
  ########################################
  # 基本情報（超重要）
  ########################################
  home.username = username;

  home.homeDirectory =
    if pkgs.stdenv.isDarwin
    then "/Users/${username}"
    else "/home/${username}";

  home.stateVersion = "24.11";

  ########################################
  # 共通パッケージ（最小）
  ########################################
  home.packages = with pkgs; [
    git
    curl
    wget
    neovim
  ];

  ########################################
  # プログラム
  ########################################
  programs.git.enable = true;
  programs.neovim.enable = true;

  ########################################
  # Nix 設定
  ########################################
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
    };
  };
}

