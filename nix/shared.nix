{ pkgs, lib, ... }:

let
  username = "nazozokc";
in
{
  home.username = username;

  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";

  home.stateVersion = "26.05";

  xdg.enable = true;

  programs.home-manager.enable = true;

  home.sessionVariables = lib.mkIf (username != null) {
    DOTFILES_USERNAME = username;
  };
}
