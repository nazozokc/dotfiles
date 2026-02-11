{ pkgs, lib, inputs, ... }:

let
  isLinux = pkgs.stdenv.isLinux;
  isDarwin = pkgs.stdenv.isDarwin;

  zen =
    if inputs ? zen-browser && isLinux
    then inputs.zen-browser.packages.${pkgs.system}.default
    else null;

in
{
  ########################################
  # 共通GUIアプリ
  ########################################

  home.packages =
    (with pkgs; [
      discord
      spotify
      vscode
      firefox
      wezterm
      ghostty
    ])
    ++ lib.optional (zen != null) zen;

  ########################################
  # 共通GUI環境変数
  ########################################

  home.sessionVariables = {
    TERMINAL = "wezterm";
  };
}

