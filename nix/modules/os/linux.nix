{ pkgs, ... }:

{
  home.packages = with pkgs; [
    xclip
    wl-clipboard
    xdg-utils
  ];

  xdg.enable = true;
  fonts.fontconfig.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "zen-browser";
  };
}

