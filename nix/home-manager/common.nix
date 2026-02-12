{ lib, config, myPkgs, ... }:

let
  homeDir = config.home.homeDirectory;
  configHome = config.xdg.configHome;
  dotfilesDir = "${homeDir}/ghq/github.com/nazozokc/dotfiles";
in
{
  ########################################
  # パッケージまとめ
  ########################################
  home.packages = with myPkgs; [
    # CLI
    cli.core
    cli.git
    cli.misc
    cli.search

    # GUI
    gui.editor
    gui.terminal
    gui.misc

    # 言語ツール
    lang.node
    lang.python
    lang.rust
    tools
  ];

  ########################################
  # .config へのリンク（Home Manager 管理下）
  ########################################
  xdg.configFile = {
    "fish" = { source = "${dotfilesDir}/fish"; force = true; };
    "nvim" = { source = "${dotfilesDir}/nvim"; force = true; };
    "wezterm" = { source = "${dotfilesDir}/wezterm"; force = true; };
  };

  ########################################
  # 追加のリンクや強制上書き（既存ファイル対策）
  ########################################
  home.activation.linkDotfilesCommon =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      echo "linking extra dotfiles (force)"

      ln -sfn "${dotfilesDir}/pip" "${homeDir}/.pip"
      ln -sfn "${dotfilesDir}/my_scripts" "${homeDir}/.scripts"
    '';

  ########################################
  # 有効化のみ
  ########################################
  programs.fish.enable = true;
  programs.neovim.enable = true;
  programs.wezterm.enable = true;
  xdg.enable = true;
  programs.home-manager.enable = true;
}

