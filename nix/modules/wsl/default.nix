# nix/modules/wsl/default.nix
# WSL 固有の home-manager 設定
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
    # ロケール
    LANG = "ja_JP.UTF-8";
    LC_ALL = "ja_JP.UTF-8";

    # Windows連携
    WSLENV = "HOME/p:USERPROFILE/p";

    # Windowsの.exe実行を許可
    WSLEXECPATH = "1";

    # ブラウザ
    BROWSER = "xdg-open";

    # エディタ
    EDITOR = "nvim";
    VISUAL = "nvim";

    # パフォーマンス最適化
    WSL_INTEROP = "/run/WSL";
  };

  ########################################
  # WSL 専用パッケージ
  ########################################
  home.packages = with pkgs; [
    # クリップボード
    xclip
    wl-clipboard

    # アーカイブ
    unzip
    zip

    # ネットワーク
    nmap

    # フォント
    fontconfig

    # セキュリティ/認証
    gnupg
    openssh

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

  ########################################
  # Git WSL向け設定
  ########################################
  programs.git = {
    enable = true;
    settings = {
      # LF統一
      core.autocrlf = "input";

      # WSL権限差分問題回避
      core.filemode = false;

      # メタデータ保持
      core.symlinks = true;
    };
  };

  ########################################
  # WSL メタデータ設定
  ########################################
  home.file.".wslconfig".text = ''
    [automount]
    enabled = true
    options = "metadata,umask=22,fmask=11"
    mountFsTab = false

    [network]
    generateResolvConf = true
    networkingMode = mirrored
  '';
}
