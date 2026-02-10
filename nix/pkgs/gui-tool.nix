{ pkgs, lib, ... }:

{
  # Home Manager で管理する GUI アプリ
  home.packages = with pkgs; [
    discord
    # wezterm は既に nvim.nix 側で管理済み
  ];
}

