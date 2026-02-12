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

    '';
}

