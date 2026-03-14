{ config, ... }:

let
  homeDir = config.home.homeDirectory;
  dotfilesDir = "${homeDir}/ghq/github.com/nazozokc/dotfiles";
  link = config.lib.file.mkOutOfStoreSymlink;
in
{
  home.file = {
    ".config/fish".source = link "${dotfilesDir}/fish";
    ".config/claude".source = link "${dotfilesDir}/claude";
    ".config/nvim".source = link "${dotfilesDir}/nvim";
    ".config/wezterm".source = link "${dotfilesDir}/wezterm";
    ".config/starship.toml".source = link "${dotfilesDir}/starship/starship.toml";
    ".config/ghostty".source = link "${dotfilesDir}/ghostty";
    ".zshrc".source = link "${dotfilesDir}/zsh/zshrc";
    ".bashrc".source = link "${dotfilesDir}/bash/bashrc";
    ".config/opencode".source = link "${dotfilesDir}/opencode";
    ".config/lazygit".source = link "${dotfilesDir}/lazygit";
  };
}
