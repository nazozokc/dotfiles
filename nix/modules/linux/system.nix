{ pkgs, ... }:

{
  ########################################
  # Linux 専用パッケージ
  ########################################
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
    bind.dnsutils
    ethtool
    mtr
    nmap

    # システム監視
    btop
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

  ########################################
  # フォント設定
  ########################################
  fonts.fontconfig.enable = true;

  ########################################
  # XDG ディレクトリ設定
  ########################################
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };
}
