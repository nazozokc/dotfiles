# packages/pacman.nix — pacman で導入するパッケージ (Arch Linux)
#
# ここに書くのは「システムのリソース」だけ。
#
#   - /etc の設定、/usr/share/man の man page
#   - systemd unit、カーネルモジュール、firmware
#
# 逆に、ユーザーの製品 (エディタ、言語ランタイム、CLI ツール) は
# Nix (home-manager の home.packages) 経由で入れる。ここには書かない。
# 二重管理になり、片方だけ古いと事故る。
#
# 照合は `pacman -T` で行う。
#   - 全て充足済みなら無出力 + rc=0
#   - 不足があれば不足名のみ stdout + rc=127
[

  # man page と補完。/usr/share に入るので Nix 側では扱わない
  "man-db"
  "bash-completion"
]
