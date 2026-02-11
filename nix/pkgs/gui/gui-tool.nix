{ pkgs, lib, zen-browser, ... }:

let
  browser =
    if pkgs.stdenv.isLinux
    then zen-browser.packages.${pkgs.system}.default
    else pkgs.firefox;
in
{
  home.packages = with pkgs; [
    discord
    spotify
    vscode
    google-chrome
    firefox
    wezterm
    ghostty
  ] ++ [ browser ];
}

