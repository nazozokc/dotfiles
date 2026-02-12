{
  lib,
  config,
  helpers,
  dotfilesDir ? "${config.home.homeDirectory}/ghq/github.com/nazozokc/dotfiles",
  ...
}:
let
  homeDir = config.home.homeDirectory;
  configHome = config.xdg.configHome;
in
{
  ########################################
  # 強制シンボリックリンク（共通）
  ########################################
  home.activation.linkDotfilesCommon =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ${helpers.activation.mkLinkForce}

      # fish
      link_force "${dotfilesDir}/fish" "${configHome}/fish"

      # neovim
      link_force "${dotfilesDir}/nvim" "${configHome}/nvim"

      # wezterm
      link_force "${dotfilesDir}/wezterm" "${configHome}/wezterm"

      # zsh
      link_force "${dotfilesDir}/zsh/zshrc" "${homeDir}/.zshrc"
      link_force "${dotfilesDir}/zsh/zshenv" "${homeDir}/.zshenv"

      # bash
      link_force "${dotfilesDir}/bash/.bashrc" "${homeDir}/.bashrc"
      link_force "${dotfilesDir}/bash/.bash_profile" "${homeDir}/.bash_profile"

      # scripts
      link_force "${dotfilesDir}/my_scripts" "${homeDir}/.scripts"

      # ideavim
      link_force "${dotfilesDir}/ideavimrc" "${homeDir}/.ideavimrc"
    '';
}

