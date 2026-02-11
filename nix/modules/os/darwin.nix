{ pkgs, ... }:

{
  home.packages = with pkgs; [
    terminal-notifier
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "zen-browser";
  };
}

