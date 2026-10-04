# packages/dnf.nix — dnf で導入するパッケージ (Fedora / RHEL 9+)
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
# 照合は `rpm -q --qf '%{NAME}\n' <宣言>` で行い、充足名を宣言から引く。
#   - NAME はアーキテクチャ接尾辞を含まない。`libz.x86_64` ではなく `libz`
#   - 充足名が1つも返らない場合は宣言全体が不足とみなす
[

  # man page と補完。/usr/share に入るので Nix 側では扱わない
  "man-pages"
  "bash-completion"
]
