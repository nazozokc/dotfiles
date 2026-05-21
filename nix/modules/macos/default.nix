# nix/modules/macos/default.nix
# macOS モジュールのエントリーポイント
# nix-darwin システム設定をここで集約
{
  imports = [
    ./system.nix
  ];
}
