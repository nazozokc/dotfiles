# nix/modules/system/default.nix
# Linux OS 層設定のエントリーポイント (numtide/system-manager)
#
# home-manager が扱えない OS 層を担当する:
#   - /etc 配下のファイル (locale / sysctl / fcitx5)
#   - systemd システムユニット・タイマー
#   - システムパッケージ
#
# 対象は「systemd ベースの Linux」。ディストリは限定しない。
#   Arch / Ubuntu / Debian / Fedora / openSUSE / Gentoo / Void / NixOS … ただし
#   実際に検証しているのは Arch Linux と Ubuntu のみ。
#   systemd 以外の init (OpenRC / runit) や musl libc のディストリ
#   (Alpine 等) は対象外の前提で、そこでのサポートはしない。
#
# モジュール構成は全ディストロで共通。プラットフォーム (x86_64 / aarch64) の
# 違いは nix/modules/system/build.nix が nixpkgs.hostPlatform としてのみ差分化する。
# ディストロ固有の分岐はここに書かず、各 submodule 側で「存在しなければ
# Warning してスキップ」する形に寄せる (存在を前提にした実装にしない)。
#
# macOS 側は nix-darwin が同じ役割を持つ。
# 参考: https://system-manager.net/main/
#
# /etc/nix/nix.conf は扱わない。nix/modules/nix-conf.nix (home-manager) が
# 全OSで ~/.config/nix/nix.conf を生成し、Nix はユーザー設定をシステム設定より
# 優先するため、OS 層で /etc/nix/nix.conf を上書きする必要はない。
{
  ...
}:

{
  imports = [
    ./locale.nix
    ./sysctl.nix
    ./power.nix
    ./input-method.nix
    ./nix-installation.nix
  ];

  # 対象プラットフォーム (nixpkgs.hostPlatform) は
  # nix/modules/system/build.nix が system 引数から注入する。
  # ここにハードコードしないことで x86_64 / aarch64 の両方で同じモジュール構成を使える。

  # system-manager のサポート対象は nixos / ubuntu / debian のみ
  # (fedora / arch / openSUSE 等は community 扱い。README 上 untested)。
  # preActivationAssertion の osVersion 検査 (=/etc/os-release の ID による許可リスト)
  # はディストリ別の問題ではないので、無効化してどの systemd 系 Linux でも通す。
  # 本物の前提条件 (systemd ベース・/etc が書ける・Nix が single/multi-user
  # どちらかで導入済み) は nix-installation.nix の assertion で別途検証する。
  system-manager.allowAnyDistro = true;
}
