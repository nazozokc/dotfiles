{ lib, config, myPkgs, ... }:

let
  homeDir    = config.home.homeDirectory;
  dotfilesDir = "${homeDir}/ghq/github.com/nazozokc/dotfiles";
in
{
  ########################################
  # dotfilesリンク
  ########################################
  xdg.configFile = {
    "fish"    = { source = "${dotfilesDir}/fish"; force = true; };
    "nvim"    = { source = "${dotfilesDir}/nvim"; force = true; };
    "wezterm" = { source = "${dotfilesDir}/wezterm"; force = true; };
  };

  home.activation.linkDotfilesCommon =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      echo "linking extra dotfiles (force)"
      ln -sfn "${dotfilesDir}/pip"         "${homeDir}/.pip"
      ln -sfn "${dotfilesDir}/my_scripts" "${homeDir}/.scripts"
    '';

  ########################################
  # プログラム有効化
  ########################################
  xdg.enable                   = true;
  programs.home-manager.enable = true;
}

