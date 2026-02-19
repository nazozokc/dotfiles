{ lib, config, ... }:

let
  homeDir = config.home.homeDirectory;
  dotfilesDir = "${homeDir}/ghq/github.com/nazozokc/dotfiles";
in
{
  # dotfiles シンボリックリンク作成
  home.activation.linkDotfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    echo "Linking extra dotfiles..."
    ln -sfn "${dotfilesDir}/fish"        "${homeDir}/.config/fish"
    ln -sfn "${dotfilesDir}/nvim"        "${homeDir}/.config/nvim"
    ln -sfn "${dotfilesDir}/wezterm"     "${homeDir}/.config/wezterm"
    ln -sfn "${dotfilesDir}/bash"     "${homeDir}/.config/bash"
  '';
}
