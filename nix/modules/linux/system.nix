# nix/modules/linux/system.nix
# Linux 固有のプログラム・セッション設定
{ pkgs, ... }:

{
  ########################################
  # 日本語入力 (fcitx5 + Mozc)
  ########################################
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
    ];
  };

  ########################################
  # ロケール設定
  ########################################
  ########################################
  # フォント設定 (non-NixOS 向け fontconfig 連携)
  ########################################
  fonts.fontconfig.enable = true;

  home.sessionVariables = {
    LANG = "ja_JP.UTF-8";
    LC_ALL = "ja_JP.UTF-8";
  };

  ########################################
  # XDG ディレクトリ設定
  ########################################
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };
}
