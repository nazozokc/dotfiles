# nix/lib/nlp.nix
# 実行体 nlp を組み立てる。
#
# apps (nix/lib/apps.nix) と tests (nix/flake-parts/checks.nix) の
# 両方から使うので、定義をこの1箇所に閉じる。
# 両方で組み立てると、テストが古いロジックを検査してしまう
{
  backends,
  declared,
  lib,
  pkgs,

  # 生成したスクリプトから shellcheck で黙らせるコード。
  # 宣言の検証 (nix/lib/declared.nix) を意図的に飛ばすテスト用の nlp では
  # 宣言に「単一引用符の中で $ を含む値」がわざと入っているため、
  # SC2016 だけを黙らせる (他の指摘は残す)
  excludeShellChecks ? [ ],
}:
let
  render = import ./render.nix;
in
pkgs.writeShellApplication {
  name = "nlp";
  inherit excludeShellChecks;

  # 照合に使う外部コマンド。
  # pacman / apt-get / dnf / rpm / zypper / yum / sudo は意図的に
  # closure に入れない。PATH 差替えで差し替えられるようにするため
  runtimeInputs = [
    pkgs.coreutils
    pkgs.gnugrep
    pkgs.gnused
  ];

  # writeShellApplication がシェバングを足し、shellcheck を通してから
  # ビルドする。生成したスクリプトの lint はここで 1 回だけかかる
  text = render { inherit backends declared lib; };
}
