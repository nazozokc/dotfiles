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
  };

  ########################################
  # Git WSL向け設定
  ########################################
  programs.git = {
    extraConfig = {
      # LF統一
      core.autocrlf = "input";

      # WSL権限差分問題回避
      core.filemode = false;
    };
  };
}
