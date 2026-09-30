# nix/modules/linux/packages.nix
# Linux 固有のパッケージ
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # クリップボード
    # wl-clipboard は Ambxst 同梱の wl-clip-persist と併用する。
    # Ambxst は履歴を SQLite で管理するため、wl-copy / wl-paste 自体は
    # nvim などの他ツール用に残す。
    xclip
    wl-clipboard

    # 音・動画
    alsa-utils
    pulseaudio
    sox

    # アーカイブ
    unzip
    zip

    # ネットワーク
    ethtool
    mtr
    nmap

    # システム監視
    duf # ディスク使用量 (modern df)
    hyperfine # ベンチマーク
    iotop
    lm_sensors
    procs # プロセス表示 (modern ps)
    sd # テキスト置換 (modern sed)
    sysstat
    bandwhich # ネットワーク使用量

    # フォント
    fontconfig
    nerd-fonts.jetbrains-mono

    # セキュリティ/認証
    gnupg
    openssh
    pass
    # Ambxst は polkit agent を同梱しないので polkit_gnome は残す
    polkit_gnome

    # XDG/デスクトップ統合
    file
    libnotify
    xdg-user-dirs
    xdg-utils

    # window manager
    herdr

    # microsoft
    teams-for-linux

    jq

    # -----------------------------------------------------------------------
    # Ambxst へ一本化したため削除したもの
    #
    #   waybar          → Ambxst bar
    #   dunst           → Ambxst notifications
    #   rofi            → Ambxst launcher (fuzzel 同梱)
    #   vicinae         → Ambxst launcher
    #   hyprlock        → Ambxst lockscreen (PAM)
    #   hypridle        → Ambxst idle / auto-lock
    #   wlogout         → Ambxst powermenu
    #   awww            → Ambxst wallpaper manager
    #   grim / slurp    → Ambxst screenshot
    #   pavucontrol     → Ambxst 同梱 (apps.nix)
    #   playerctl       → Ambxst 同梱 (media.nix) + media key OSD
    #   brightnessctl   → Ambxst 同梱 (tools.nix) + brightness OSD
    # -----------------------------------------------------------------------
  ];
}
