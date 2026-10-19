# nix/modules/nixos/default.nix
# NixOS システム設定のエントリーポイント
#
# nix/modules/system/ (system-manager 用) とは別モジュールツリー:
#   system-manager … /etc を直接管理 (environment.etc + oneshot)。全ディストロ共通
#   NixOS          … ネイティブオプション (i18n / console / users / boot) が正
#
# ここで import するのは NixOS でそのまま動く共有モジュールと
# NixOS 固有の system.nix だけ。power.nix / nix-installation.nix は
# system-manager 固有のオプションを使うため import しない。
{
  imports = [
    # 共有モジュール (replaceExisting の有無で両対応)
    ../system/sysctl.nix
    ../system/input-method.nix
    ../system/locale.nix

    ./system.nix
  ];
}
