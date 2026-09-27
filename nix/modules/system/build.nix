# nix/modules/system/build.nix
# Linux 向け OS 層設定を生成するヘルパー (mkSystemConfig)
# x86_64 / aarch64 で共通のモジュール構成を使い回す
{
  system-manager,
  username,
}:
system:
system-manager.lib.makeSystemConfig {
  # username をモジュールへ渡す (nix/modules/system/ 側からの参照用)
  specialArgs = { inherit username; };

  modules = [
    ./default.nix

    # 対象プラットフォーム。
    # ここで固定することで:
    #   - systemConfigs の derivation が実行マシンに依存しない
    #     (macOS CI 上の `nix flake check` でも同じ設定が評価される)
    #   - 各 submodule で nixpkgs.hostPlatform を書かずに済む
    # system-manager 側の nixpkgs.hostPlatform は mkDefault なので _declared_ 側が優先される
    {
      nixpkgs.hostPlatform = system;
    }
  ];
}
