{ config, pkgs, lib, ... }:

{
  # Linux / Mac 共通設定
  home.stateVersion = lib.mkForce "24.05";

  home.username = "nazozokc";

  home.homeDirectory =
    if pkgs.stdenv.isDarwin
    then "/Users/nazozokc"
    else "/home/nazozokc";

  # sessionVariables はここでも定義可能
  home.sessionVariables = {
    PATH = builtins.concatStringsSep ":" [
      (if pkgs.stdenv.isDarwin then "/nix/var/nix/profiles/default/bin" else "")
      "$HOME/.nix-profile/bin"
      "$PATH"
    ];
  };
}

