{ lib, config, myPkgs, ... }:

let
  homeDir    = config.home.homeDirectory;
  dotfilesDir = "${homeDir}/ghq/github.com/nazozokc/dotfiles";

in
{
  ########################################
  # dotfilesリンクだけ作る
  ########################################
  home.activation.linkDotfilesCommon =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      echo "linking extra dotfiles (force)"
      ln -sfn "${dotfilesDir}/fish"        "${homeDir}/.config/fish"
      ln -sfn "${dotfilesDir}/nvim"        "${homeDir}/.config/nvim"
      ln -sfn "${dotfilesDir}/wezterm"     "${homeDir}/.config/wezterm"
      ln -sfn "${dotfilesDir}/pip"         "${homeDir}/.pip"
      ln -sfn "${dotfilesDir}/my_scripts"  "${homeDir}/.scripts"
    '';

  ########################################
  # xdg と home-manager は有効にしておく
  ########################################
  xdg.enable               = true;
  programs.home-manager.enable = true;
}

