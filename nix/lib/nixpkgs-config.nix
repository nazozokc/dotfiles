# nix/lib/nixpkgs-config.nix
# nixpkgs.config の単一ソース。
#
# pkgsFor (nix/lib/pkgs.nix) / nix-darwin (nix/modules/macos/build.nix) /
# NixOS (nix/modules/nixos/build.nix) が同じ値を使う。
# ここがずれると「unfree 許可あり / なし」の二状態が生まれ、
# 同一パッケージが評価経路によって解決できたりできなかったりする。
{
  # x86_64-darwin は 26.05 系スタックを使うため、26.05 の非推奨警告を抑止する。
  # 26.11 ではキー自体が不要 (未知のキーは無視される)。
  allowDeprecatedx86_64Darwin ? false,
  # nixpkgs.config はモジュール評価時に { lib, ... } で呼ばれるため、
  # 未知の引数 (lib) を捨てる。直接 import する場合も同じ関数で扱える。
  ...
}:

{
  allowUnfree = true;
  inherit allowDeprecatedx86_64Darwin;
  permittedInsecurePackages = [
    "pnpm-9.15.9"
    "pnpm-10.34.0"
    "electron-39.8.10"
  ];
  problems = {
    handlers.dlinfo.broken = "warn";
  };
}
