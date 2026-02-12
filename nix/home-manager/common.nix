{ lib, pkgs, config, ... }:

with pkgs;

let
  # パッケージ
  cliPkgs  = import ../pkgs/cli/default.nix  { inherit pkgs; };
  guiPkgs  = import ../pkgs/gui/default.nix  { inherit pkgs; };
  langPkgs = import ../pkgs/lang/default.nix { inherit pkgs; };

  homeDir    = config.home.homeDirectory;
  dotfilesDir = "${homeDir}/ghq/github.com/nazozokc/dotfiles";
in
{
  # パッケージのインストール
  home.packages = cliPkgs ++ guiPkgs ++ langPkgs;

  # dotfiles シンボリックリンク
  home.activation.linkDotfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    echo "Linking extra dotfiles..."
    ln -sfn "${dotfilesDir}/fish"        "${homeDir}/.config/fish"
    ln -sfn "${dotfilesDir}/nvim"        "${homeDir}/.config/nvim"
    ln -sfn "${dotfilesDir}/wezterm"     "${homeDir}/.config/wezterm"
    ln -sfn "${dotfilesDir}/pip"         "${homeDir}/.pip"
    ln -sfn "${dotfilesDir}/my_scripts"  "${homeDir}/.scripts"
  '';
}

