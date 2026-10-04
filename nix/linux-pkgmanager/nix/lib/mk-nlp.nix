# nix/lib/mk-nlp.nix
# 配布用の公開関数。
#
# 他の flake から宣言を差し込んで nlp を組み立てる。
# flake-parts なら flakeModules.default と nlp.declared を使う。
# これはその下の関数で、実行体だけが欲しいときに呼ぶ。
#
#   packages.<system>.default = inputs.nlp.lib.mkNlp {
#     inherit pkgs;
#     declared = {
#       pacman = [ "man-db" "bash-completion" ];
#       apt = [ "man-db" "bat" ];
#     };
#   };
#
# なぜ input 属性ではなく関数なのか:
# flake の input に許されるのは url / follows / inputs だけで、
# `declared = { ... }` を渡すと
#   error: flake input attribute 'declared' is a thunk while a string,
#   Boolean, or integer is expected
# で弾かれる。宣言は「値」なので input には載らず、関数で渡すのが正解。
#
# 未知の pm 名・リストでない宣言・pm が受理できないパッケージ名は
# すべてここで評価時に落とす (nix/lib/declared.nix)。
# 黙って無視すると、その宣言だけ永久に効かないまま「不足なし」と嘘をつく
{
  lib,
  backends,
  validate,
}:
{ pkgs, declared }:
import ./nlp.nix {
  inherit lib backends pkgs;
  declared = validate declared;
}
