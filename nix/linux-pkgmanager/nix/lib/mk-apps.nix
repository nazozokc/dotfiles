# nix/lib/mk-apps.nix
# flake-parts を使わない消費側向け。
#
# mkNlp は実行体だけを返す。消費側が diff / apply / update / status を
# 自分の flake の apps として出すには、ラッパーまでこちらで組む。
#
#   outputs = { nixpkgs, linux-pkgmanager.nix, ... }:
#     let
#       built = linux-pkgmanager.nix.lib.mkApps {
#         pkgs = nixpkgs.legacyPackages.x86_64-linux;
#         declared.pacman = [ "man-db" "bash-completion" ];
#       };
#     in {
#       packages.x86_64-linux.nlp = built.package;
#       apps.x86_64-linux = built.apps;
#     };
#
# 宣言の検査は mkNlp と同じ validate を通す。
{
  lib,
  backends,
  validate,
}:
{
  pkgs,
  declared,
  appPrefix ? "nlp-",
  defaultApp ? null,
}:
let
  nlp = import ./mk-nlp.nix { inherit lib backends validate; } { inherit pkgs declared; };
in
import ./apps.nix {
  inherit
    lib
    pkgs
    nlp
    appPrefix
    defaultApp
    ;
}
