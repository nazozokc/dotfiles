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
    # VSCode は GUI パッケージ (packages/gui) と同じ範囲 (Linux + macOS) のみ。
    # WSL は GUI パッケージ除外の設計なので wsl.nix 経由では読まない
    ./programs/vscode
    ./packages
  ];
}
