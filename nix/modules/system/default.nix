# nix/modules/system/default.nix
# Linux OS 層設定のエントリーポイント (numtide/system-manager)
#
# home-manager が扱えない OS 層を担当する:
#   - /etc 配下のファイル (locale / sysctl / fcitx5 / nix.conf)
#   - systemd システムユニット・タイマー
#   - システムパッケージ
#
# モジュール構成は systemd ベースの全 Linux ディストロで共通。
# プラットフォーム (x86_64 / aarch64) の違いは nix/modules/system/build.nix が
# nixpkgs.hostPlatform としてのみ差分化する。
#
# macOS 側は nix-darwin が同じ役割を持つ。
# 参考: https://system-manager.net/main/
#
# /etc/nix/nix.conf は扱わない。nix/modules/nix-conf.nix (home-manager) が
# 全OSで ~/.config/nix/nix.conf を生成し、Nix はユーザー設定をシステム設定より
# 優先するため、OS 層で /etc/nix/nix.conf を上書きする必要はない。
{
  username,
  ...
}:

{
  imports = [
    ./locale.nix
    ./sysctl.nix
    ./power.nix
    ./input-method.nix
  ];

  # 対象プラットフォーム (nixpkgs.hostPlatform) は
  # nix/modules/system/build.nix が system 引数から注入する。
  # ここにハードコードしないことで x86_64 / aarch64 の両方で同じモジュール構成を使える。

  # system-manager のサポート対象は nixos / ubuntu / debian のみ
  # (fedora / arch は community 扱い。README 上 untested)。
  # Arch を含む未対応ディストロで動かすため、preActivationAssertion の
  # osVersion 検査を skip する。前提条件 (systemd ベース) は満たす。
  system-manager.allowAnyDistro = true;

  # Nix は single-user モード (nix-daemon 無し) で運用する。
  # installer が作る /nix/store は root:nixbld 1775 なので、
  # store へ書き込むには実行用户在 nixbld グループに居る必要がある。
  #
  # userborn は宣言どおりの /etc/group を書き戻すため、
  # installer が追加した所属を消してしまう。
  # ここで宣言して所属を維持する (users.users を宣言すると userborn に
  # ユーザー管理を丸投げするため、グループの members だけ指定する)。
  users.groups.nixbld.members = [ username ];
}
