# nix/modules/linux/packages.nix
# Linux 固有のパッケージ
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # クリップボード
    xclip
    wl-clipboard

    # 音・動画
    alsa-utils
    playerctl
    pulseaudio
    pavucontrol
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
    polkit_gnome

    # XDG/デスクトップ統合
    file
    libnotify
    xdg-user-dirs
    xdg-utils

    # window manager
    herdr

    # スクリーンショット
    grim
    slurp

    # バックライト
    brightnessctl

    # ランチャー
    rofi

    # ステータスバー
    waybar

    # 通知
    dunst

    # ウォールペーパー
    awww

    # ロック/アイドル
    hyprlock
    hypridle

    # ログアウトメニュー
    wlogout
  ];
}
