{ pkgs, username, ... }:

{
  home.username = username;

  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";

  # Keep in sync with your nixpkgs channel version
  home.stateVersion = "26.11";

  home.enableNixpkgsReleaseCheck = false;

  xdg.enable = true;

  programs.home-manager.enable = true;

  home.sessionVariables = {
    DOTFILES_USERNAME = username;
  };
}
