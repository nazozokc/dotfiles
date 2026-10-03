# nix/lib/packages/shared.nix
# ネイティブ Linux と WSL の両方に導入する共通パッケージ。
#
# なぜここへ出すか:
#   このリストは単一ソースであり、nix/modules/{linux,wsl}/packages.nix は
#   「この共通セット + 環境固有のもの」とだけ定義する。
#   共通パッケージを両モジュールへ並べて書くと、片方だけ更新して
#   もう片方が古くなったまま残る。
#
# 使い方:
#   home.packages = (import ../../lib/packages/shared.nix { inherit pkgs; }) ++ [
#     ...環境固有...
#   ];
{ pkgs }:

with pkgs;
[
  # クリップボード
  # wl-clipboard は Ambxst 同梱の wl-clip-persist と併用する。
  # Ambxst は履歴を SQLite で管理するため、wl-copy / wl-paste 自体は
  # nvim などの他ツール用に残す。
  xclip
  wl-clipboard

  # アーカイブ
  unzip
  zip

  # ネットワーク
  nmap

  # フォント
  fontconfig

  # セキュリティ/認証
  gnupg
  openssh

  # XDG/デスクトップ統合
  file
  libnotify
  xdg-user-dirs
  xdg-utils

  # window manager
  herdr
]
