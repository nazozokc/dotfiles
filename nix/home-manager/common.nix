{ lib, config, ... }:

let
  # flake ルートからの相対パスを使う
  dotfilesDir = ./dotfiles;
  homeDir = config.home.homeDirectory;
in
{
  ########################################
  # dotfilesリンク（flake 内の相対パスを使用）
  ########################################
  xdg.configFile = {
    "fish"    = { source = "${dotfilesDir}/fish"; force = true; };
    "nvim"    = { source = "${dotfilesDir}/nvim"; force = true; };
    "wezterm" = { source = "${dotfilesDir}/wezterm"; force = true; };
  };

  home.activation.linkDotfilesCommon =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      echo "linking extra dotfiles (force)"
      ln -sfn "${dotfilesDir}/pip"        "${homeDir}/.pip"
      ln -sfn "${dotfilesDir}/my_scripts" "${homeDir}/.scripts"
    '';

  ########################################
  # プログラム有効化は最低限
  ########################################
  xdg.enable                 = true;
  programs.home-manager.enable = true;
}

