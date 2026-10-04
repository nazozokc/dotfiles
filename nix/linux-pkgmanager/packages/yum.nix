# packages/yum.nix — yum で導入するパッケージ (RHEL 7 / CentOS 7)
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
#
# 注意:
#   - RHEL 7 系の rpm には `--userinstalled` タグがないため、
#     明示導入と依存導入を区別できない。unmanaged には依存も混ざる
#   - man ページは Fedora の `man-pages` ではなく `man` に含まれる
[

  # man page と補完。/usr/share に入るので Nix 側では扱わない
  "man"
  "bash-completion"
]
