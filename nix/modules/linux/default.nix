# nix/modules/linux/default.nix
# Linux 固有の home-manager 設定
{ pkgs, ... }:

{
  ########################################
  # ロケール設定
  ########################################
  home.sessionVariables = {
    LANG = "ja_JP.UTF-8";
    LC_ALL = "ja_JP.UTF-8";
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    SDL_IM_MODULE = "fcitx";
    GLFW_IM_MODULE = "ibus";
  };

  ########################################
  # Linux 専用パッケージ
  ########################################
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
