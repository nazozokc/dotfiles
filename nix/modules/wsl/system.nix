# nix/modules/wsl/system.nix
# WSL 固有のプログラム・セッション設定
{
  config,
  pkgs,
  dotfilesDir,
  ...
}:

let
  link = config.lib.file.mkOutOfStoreSymlink;
in
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

    # ブラウザ
    BROWSER = "xdg-open";

    # エディタ
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

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
  # NOTE: .wslconfig は Windows 側 (%USERPROFILE%\.wslconfig) のファイルであり、
  #       WSL の Linux 側 ~/.wslconfig は読まれない。
  #       windows/apply.ps1 経由で wsl/.wslconfig を symlink するためここでは管理しない。
  #       /etc/wsl.conf は root 権限が必要なため my_scripts/wsl-setup.sh で管理する。

  home.file = {
    ".config/hypr".source = link "${dotfilesDir}/hypr";
  };

}
