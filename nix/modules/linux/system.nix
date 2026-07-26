# nix/modules/linux/system.nix
# Linux 固有のプログラム・セッション設定
{ config, pkgs, ... }:

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

  ########################################
  # Ghostty D-Bus activation の修正
  ########################################
  # パッケージ標準の com.mitchellh.ghostty.service は SystemdService を
  # 参照しており該当 unit が存在しないため activation に失敗する。
  # ユーザーサービスで上書きし、systemd を介さず直接 Exec する。
  xdg.dataFile."dbus-1/services/com.mitchellh.ghostty.service" = {
    text = ''
      [D-BUS Service]
      Name=com.mitchellh.ghostty
      Exec=${config.home.homeDirectory}/.nix-profile/bin/ghostty --gtk-single-instance=true --initial-window=false
    '';
    force = true;
  };
}
