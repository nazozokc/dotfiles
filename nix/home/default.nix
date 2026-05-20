# nix/home/default.nix
# home-manager設定のエントリーポイント
# 各プラットフォーム共通のモジュールをここで集約する
{
  pkgs,
  dotfilesDir,
  username,
  ...
}:
{
  imports = [
    ./dotfiles-link.nix
    ./programs/nvim/default.nix
    ./agent-skills.nix
    ./programs-common.nix
    ./packages
  ];
}
