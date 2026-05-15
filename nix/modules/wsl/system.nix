{ pkgs, ... }:

{
  ########################################
  # WSL 専用パッケージ
  ########################################
  home.packages = with pkgs; [
    # アーカイブ（Linuxから引き継ぎ）
    unzip
    zip

    # ネットワーク
    nmap

    # WSL相互運用
    wslu # WSL <-> Windows 相互運用ツール
  ];

  ########################################
  # WSL 向け環境変数
  ########################################
  home.sessionVariables = {
    # Windows連携
    WSLENV = "HOME/p:USERPROFILE/p";

    # デフォルトブラウザをWSL側に委譲
    BROWSER = "wslview";

    # エディタ
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  ########################################
  # Git WSL向け設定
  ########################################
  programs.git = {
    extraConfig = {
      # 改行コード: WSLではLF統一
      core.autocrlf = "input";
      # ファイルモード変更を検知しない（WSLのファイルシステム問題回避）
      core.filemode = false;
    };
  };

  ########################################
  # Windows相互運用
  ########################################
  # WindowsコマンドをWSLから呼び出すための設定
  home.sessionVariables = {
    # Windowsの.exeをPATHから検索可能にする（デフォルト有効な場合が多いが明示）
    WSLEXECPATH = "1";
  };
}
