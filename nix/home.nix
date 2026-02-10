{ config, pkgs, ... }:

{
  # 共通設定
  home.username = "nazozokc";
home.homeDirectory = "/home/${config.home.username}";

  # モジュール読み込み
  imports = [
    ./home/fish.nix
  ];
}

