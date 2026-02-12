{ config, pkgs, lib, username, system, ... }:

{
  ########################################
  # 基本情報
  ########################################
  home.username = username;

  home.homeDirectory =
    if pkgs.stdenv.isDarwin
    then "/Users/${username}"
    else "/home/${username}";

  home.stateVersion = "24.11";

  ########################################
  # 共通 pkgs 読み込み
  ########################################
  imports = [
    ./pkgs
  ];

  ########################################
  # 共通プログラム設定
  ########################################
  programs.git = {
    enable = true;
    userName = "nazozo";
    userEmail = "example@example.com";
  };

  programs.neovim.enable = true;
  programs.fish.enable = true;

  ########################################
  # Nix 設定
  ########################################
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}

