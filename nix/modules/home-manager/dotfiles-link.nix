{ config, ... }:

let
  dotfilesDir = "${config.home.homeDirectory}/ghq/github.com/nazozokc/dotfiles";
  link = config.lib.file.mkOutOfStoreSymlink;
in
{
  home.file = {
    "commitlint.config.js".source = link "${dotfilesDir}/commitlint.config.js";
    ".config/fish".source = link "${dotfilesDir}/fish";
    ".config/wezterm".source = link "${dotfilesDir}/wezterm";
    ".config/ghostty".source = link "${dotfilesDir}/ghostty";
    ".zshrc".source = link "${dotfilesDir}/zsh/zshrc";
    ".bashrc".source = link "${dotfilesDir}/bash/bashrc";
  };
}
