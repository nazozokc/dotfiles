{ config, pkgs, ... }:

{
  # fish を有効化（home.nix 内からも呼べる）
  programs.fish.enable = true;

  # fish ディレクトリをリンク
  home.file.".config/fish".source = ./fish;
}

