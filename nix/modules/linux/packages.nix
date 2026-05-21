# nix/modules/linux/packages.nix
# Linux 固有のパッケージ
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # 日本語入力
    fcitx5
    fcitx5-mozc
    fcitx5-gtk

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
    bind.dnsutils
    ethtool
    mtr
    nmap

    # システム監視
    iotop
    lm_sensors
    sysstat

    # フォント
    fontconfig

    # セキュリティ/認証
    gnupg
    openssh
    pass

    # XDG/デスクトップ統合
    file
    libnotify
    xdg-user-dirs
    xdg-utils
  ];
}
