# packages/apt.nix — apt で導入するパッケージ (Debian / Ubuntu)
#
# ここに書くのは「システムのリソース」だけ。
#
#   - /etc の設定、/usr/share/man の man page
#   - init system の unit、カーネルモジュール、firmware
#
# 逆に、ユーザーの製品 (エディタ、言語ランタイム、CLI ツール) は
# Nix (home-manager の home.packages) 経由で入れる。ここには書かない。
# 二重管理になり、片方だけ古いと事故る。
#
# 照合は `apt-get install --simulate` で行い、`^Inst ` 行を不足と見る。
# そのため:
#
#   - 名前は実際の binary:Package を書く。virtual package や
#     provides だけを書いても照合は通らない
#     (2026-10 時点: `batcat` は無くなり `bat` が正式名。
#      古い Debian / Ubuntu なら `batcat` になる)
#   - 存在しない名前を混ぜると apt は E: で異常終了し、Inst 行が1行も出ない。
#     nlp は stderr の E: 行を検出するので放置しないこと
[

  # man page と補完。/usr/share に入るので Nix 側では扱わない
  "man-db"
  "bash-completion"

  # ripgrep 風の多段表示つき cat
  "bat"
]
