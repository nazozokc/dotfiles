# nix/modules/system/input-method.nix
# 日本語入力 (fcitx5 + Mozc) の OS 層設定
#
# 役割分担:
#   - デーモンの起動と mozc addon は home-manager の i18n.inputMethod
#     (systemd/user/fcitx5-daemon.service + qt6Packages.fcitx5-with-addons) が担当
#   - ここ (/etc) はシステム既定の環境変数と fcitx5 グローバル設定のみ
#
# 意図的に行わないこと:
#   - /etc/xdg/autostart/fcitx5-autostart.desktop を作らない
#     (home-manager の user サービスと二重起動するため)
#   - fcitx5 を environment.systemPackages に入れない
#     (home-manager 側が fcitx5-with-addons を user -Service で起動するため、
#      PATH 上で 2 種類の fcitx5 が競合し設定ディレクトリも分散する)
{
  ...
}:

{
  environment.etc = {
    # システム既定の入力メソッド環境変数。
    # home-manager が ~/.config/environment.d/10-home-manager.conf に同値を
    # 出力するため、ユーザーセッションでは home-manager 側が優先される。
    # systemd --user を通らない経路 (TTY 直起動など) 用のフォールバック。
    "environment.d/99-fcitx5.conf" = {
      text = ''
        GTK_IM_MODULE=fcitx
        QT_IM_MODULE=fcitx
        XMODIFIERS=@im=fcitx
      '';
      mode = "0644";
    };

    # fcitx5 のグローバル設定 (/etc/xdg/fcitx5 はユーザー設定 ~/.config/fcitx5 より優先)
    "xdg/fcitx5/profile" = {
      text = ''
        [Groups/0]
        Name=Default
        Default Layout=us
        DefaultIM=mozc

        [Groups/0/Items/0]
        Name=keyboard-us
        Layout=

        [Groups/0/Items/1]
        Name=mozc
        Layout=

        [Groups/0/Items/2]
        Name=mozc-jp
        Layout=

        [GroupOrder]
        0=Default
      '';
      mode = "0644";
    };
  };
}
