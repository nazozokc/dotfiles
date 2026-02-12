{ lib, config, myPkgs, ... }:

let
  homeDir   = config.home.homeDirectory;
  configHome = config.xdg.configHome;
  dotfilesDir = "${homeDir}/ghq/github.com/nazozokc/dotfiles";

  ########################################
  # 各 myPkgs をフラット化
  ########################################
  cliPkgs = lib.concatMap (x: x) myPkgs.cli;
  guiPkgs = lib.concatMap (x: x) myPkgs.gui;
  langPkgs = lib.concatMap (x: x) myPkgs.lang;
in
{
  ########################################
  # インストールするパッケージ
  ########################################
  home.packages = cliPkgs ++ guiPkgs ++ langPkgs ++ myPkgs.tools;

  ########################################
  # dotfilesリンク
  ########################################
  xdg.configFile = {
    "fish"   = { source = "${dotfilesDir}/fish"; force = true; };
    "nvim"   = { source = "${dotfilesDir}/nvim"; force = true; };
    "wezterm"= { source = "${dotfilesDir}/wezterm"; force = true; };
  };

  home.activation.linkDotfilesCommon =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      echo "linking extra dotfiles (force)"
      ln -sfn "${dotfilesDir}/pip"        "${homeDir}/.pip"
      ln -sfn "${dotfilesDir}/my_scripts" "${homeDir}/.scripts"
    '';

  ########################################
  # プログラム有効化
  ########################################
  xdg.enable               = true;
  programs.home-manager.enable = true;
}

