{ pkgs, username, ... }:
{
  home.username = username;

  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";

  home.stateVersion = "26.05";

  xdg.enable = true;

  programs.home-manager.enable = true;

  home.sessionVariables = {
    DOTFILES_USERNAME = username;
  };
}
