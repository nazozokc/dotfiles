# nix/modules/linux/kde.nix
# KDE Plasma 設定 (home-manager で宣言的管理)
# 管理範囲: ウィンドウ装飾, アイコン, カーソル, ロケール
# 管理しない: フォント, カラースキーム, パネル/Dock レイアウト（KDE System Settings）
{ ... }:
{
  home.file = {
    # ===== kwinrc: ウィンドウ装飾・タイリング =====
    # 装飾テーマ: MacTahoe-Light (Aurorae)
    # ボタン配置: XIA (閉じる/最小化/最大化) を左側 (macOS style)
    ".config/kwinrc".text = ''
      [Desktops]
      Number=1
      Rows=1

      [Tiling]
      padding=4

      [Xwayland]
      Scale=1

      [org.kde.kdecoration2]
      ButtonsOnLeft=XIA
      ButtonsOnRight=
      library=org.kde.kwin.aurorae.v2
      theme=__aurorae__svg__MacTahoe-Light
    '';

    # ===== kdeglobals: アイコンテーマ =====
    ".config/kdeglobals".text = ''
      [Icons]
      Theme=MacTahoe

      [KDE]
      contrast=4
      frameContrast=0.2

      [KFileDialog Settings]
      Allow Expansion=false
      Automatically select filename extension=true
      Breadcrumb Navigation=true
      Show hidden files=false
      Sort by=Name
      Sort directories first=true
      Sort reversed=false
      View Style=DetailTree
    '';

    # ===== kcminputrc: カーソルテーマ =====
    ".config/kcminputrc".text = ''
      [Mouse]
      cursorTheme=MacTahoe
    '';

    # ===== plasma-localerc: ロケール =====
    ".config/plasma-localerc".text = ''
      [Formats]
      LANG=ja_JP.UTF-8
    '';
  };
}
