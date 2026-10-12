# nix/modules/home/default.nix
# home-manager設定のエントリーポイント
# 各プラットフォーム共通のモジュールをここで集約する
{
  imports = [
    ./dotfiles-link.nix
    ./programs/herdr
    ./programs/nvim/default.nix
    ./agent-skills.nix
    ./programs-common.nix
    ./packages
  ];
}
