{ lib, config, ... }:
let
  homeDir = config.home.homeDirectory;
  configHome = config.xdg.configHome;
  dotfilesDir = "${homeDir}/ghq/github.com/nazozokc/dotfiles";
in
{
  home.activation.linkDotfilesCommon =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      echo "linking dotfiles (force)"

      ln -sfn "${dotfilesDir}/fish" "${configHome}/fish"
      ln -sfn "${dotfilesDir}/nvim" "${configHome}/nvim"
      ln -sfn "${dotfilesDir}/wezterm" "${configHome}/wezterm"
    '';
}

