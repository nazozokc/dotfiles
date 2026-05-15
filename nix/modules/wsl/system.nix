{ pkgs, ... }:

{
  ########################################
  # WSL 専用パッケージ
  ########################################
  home.packages = with pkgs; [
    # アーカイブ
    unzip
    zip

    # ネットワーク
    nmap

    # Windows連携ツール (win32yank.exeはWindows側から直接利用可能)
  ];

  ########################################
  # WSL 向け環境変数
  ########################################
  home.sessionVariables = {
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
  '';
}
