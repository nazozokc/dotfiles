{ pkgs, lib, ... }:

{
  home.packages =
    lib.optionals pkgs.stdenv.isLinux (with pkgs; [
      firefox
    ])
    ++ lib.optionals pkgs.stdenv.isDarwin (with pkgs; [
      # macOS では GUI は最小限
    ]);
}

