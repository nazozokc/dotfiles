{ pkgs, ... }:

{
  ########################################
  # ロケール設定
  ########################################
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
    ];
  };

  home.sessionVariables = {
    LANG = "ja_JP.UTF-8";
    LC_ALL = "ja_JP.UTF-8";
  };

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

  ########################################
  # XDG ディレクトリ設定
  ########################################
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };
}
