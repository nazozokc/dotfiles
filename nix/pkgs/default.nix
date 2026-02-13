{ pkgs }:

let
  ########################################
  # CLI ツール群
  ########################################
  cli = import ./cli-default.nix { inherit pkgs; };

  ########################################
  # GUI アプリ群
  ########################################
  gui = import ./gui-default.nix { inherit pkgs; };

  ########################################
  # 言語・開発系
  ########################################
  lang = import ./lang-default.nix { inherit pkgs; };

in
{
  inherit cli gui lang;
}

