# config-update 専用モジュール
#
# home-manager の activate は必ず installPackages を実行し、
# ~/.nix-profile (nix profile / nix-env) のパッケージを切り替える。
# これを無効化して、設定ファイル・symlink・その他の activation だけを反映する。
#
# writeBoundary は --driver-version 1 のとき既にスキップされるので不要。
{ lib, ... }:
{
  home.activation.installPackages = lib.mkForce "";
}
