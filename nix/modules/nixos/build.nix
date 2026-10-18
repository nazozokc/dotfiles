# nix/modules/nixos/build.nix
# NixOS 向けシステム設定生成ヘルパー (mkNixosConfig)
# x86_64 / aarch64 で共通のモジュール構成を使い回す
#
# system-manager (非 NixOS ディストロ) と NixOS は別モジュールツリーを使う:
#   - system-manager … nix/modules/system/  (environment.etc + oneshot)
#   - NixOS          … nix/modules/nixos/   (ネイティブ i18n / boot / users)
#
# 共有できるモジュール (nix/modules/system/ のうち):
#   - sysctl.nix       … environment.etc."sysctl.d" だけ。NixOS でもそのまま動く
#   - input-method.nix … replaceExisting を有無で条件分岐済み。両対応
#   - locale.nix       … 同上。NixOS では locale.conf / vconsole.conf / oneshot を
#                        skip し、i18n.defaultLocale と console.keyMap が正
#
# 共有しないモジュール:
#   - power.nix            … NixOS には services.power-profiles-daemon.enable が有る
#   - nix-installation.nix … system-manager.preActivationAssertions が NixOS に無く評価エラー
{
  nixpkgs,
  username,
  overlay,
}:
system: hostModule:
nixpkgs.lib.nixosSystem {
  inherit system;
  # username をモジュールへ渡す (nix/modules/nixos/ 側からの参照用)
  specialArgs = { inherit username; };
  modules = [
    # 共有モジュール (system-manager と同じ実体を両対応化してある)
    ../system/sysctl.nix
    ../system/input-method.nix
    ../system/locale.nix

    ./default.nix
    hostModule

    {
      # nixpkgs の config は pkgs.nix (pkgsFor) と同値にする。
      # 理由: home-manager 側は pkgsFor で pkgs を組むため、
      #   NixOS の nixpkgs.config と食い違うと
      #   「unfree 許可あり / なし」の二状態が生まれる。
      nixpkgs.config = {
        allowUnfree = true;
        permittedInsecurePackages = [
          "pnpm-9.15.9"
          "pnpm-10.34.0"
          "electron-39.8.10"
        ];
        problems = {
          handlers.dlinfo.broken = "warn";
        };
      };
      # overlay も pkgsFor と同値。llm-agents / gh-graph / gh-nippou の
      # overlay は home-manager のパッケージ解決でしか使わないので OS 層では不要
      nixpkgs.overlays = [ overlay ];
    }
  ];
}
