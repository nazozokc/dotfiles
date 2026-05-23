# nix/modules/home/wsl.nix
# WSL 向け home-manager エントリーポイント
# packages は wsl/tools-read.nix で管理するためここでは読まない
{
  imports = [
    ./dotfiles-link.nix
    ./programs/nvim/default.nix
    ./agent-skills.nix
    ./programs-common.nix
    # NOTE: packages/ は読まない（GUI パッケージを除外するため）
    # WSL のパッケージは nix/modules/wsl/tools-read.nix 経由で wsl.nix を使用
  ];
}
