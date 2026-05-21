# nix/modules/linux/default.nix
# Linux モジュールのエントリーポイント
# 各責務を packages.nix / programs.nix に分離
{
  imports = [
    ./packages.nix
    ./programs.nix
  ];
}
