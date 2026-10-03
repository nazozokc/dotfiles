# nix/modules/wsl/packages.nix
# WSL 固有のパッケージ
#
# ネイティブ Linux と WSL で共通するパッケージは
# nix/lib/packages/shared.nix が単一ソースで持つ。WSL では GUI アプリと
# デスクトップ用途のパッケージを入れないので、この共通セットだけで足りる。
{ pkgs, ... }:

{
  home.packages = import ../../lib/packages/shared.nix { inherit pkgs; };
}
