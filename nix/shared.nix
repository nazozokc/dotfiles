{ pkgs, username, ... }:

{
  ########################################
  # 基本情報（共通）
  ########################################
  home.username = username;

  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";

  # Home Manager の互換性バージョン
  home.stateVersion = "24.05";

  ########################################
  # XDG 有効化（.config 管理用）
  ########################################
  xdg.enable = true;

  ########################################
  # Home Manager 自身を有効化
  ########################################
  programs.home-manager.enable = true;
}
