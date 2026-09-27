# nix/modules/system/default.nix
# Linux OS 層設定のエントリーポイント (numtide/system-manager)
#
# home-manager が扱えない OS 層を担当する:
#   - /etc 配下のファイル (locale / sysctl / fcitx5 / nix.conf)
#   - systemd システムユニット・タイマー
#   - システムパッケージ
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
  ];

  # 対象プラットフォーム。
  # ここで固定することで:
  #   - systemConfigs の derivation が実行マシンに依存しない
  #     (macOS CI 上の `nix flake check` でも同じ設定が評価される)
  #   - 各 submodule で nixpkgs.hostPlatform を書かずに済む
  # system-manager 側の nixpkgs.hostPlatform は mkDefault なので_declared_ 側が優先される
  nixpkgs.hostPlatform = "x86_64-linux";

  # system-manager のサポート対象は nixos / ubuntu / debian のみ。
  # Arch は未対応ディストリのため、preActivationAssertion の osVersion 検査を skip する。
  # なお Arch は systemd ベースなので前提条件は満たす (README 上 untested)。
  system-manager.allowAnyDistro = true;
}
