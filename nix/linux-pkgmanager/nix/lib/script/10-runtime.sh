# shellcheck shell=bash
# nix/lib/script/10-runtime.sh — 実行時の共通設定と小さな道具
#
# このファイルの責務は「全部のファイルが前提とする設定」だけ。
# 照合・表示・コマンドの各ファイルはこの上に積み上げる。
#
# 決めていること
#   set -euo pipefail : 失敗を黙って続行しない
#   set -f            : IFS による分割を成立させるため glob を切る
#   LC_ALL=C          : sort / grep の並び順を実行環境に依存させない
#                       (comm は「両方ソート済み」を前提にする。ロケールが
#                        違うと同じ内容でも並びがズレて結果が壊れる)
#   色変数           : TTY かつ NO_COLOR 未指定のときだけ付ける
#
# 色変数は report / commands から参照するため、このファイルでは
# 代入されるだけになる。
# shellcheck disable=SC2034

set -euo pipefail
set -f
export LC_ALL=C

if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  C_B=$'\033[1m'
  C_D=$'\033[2m'
  C_R=$'\033[31m'
  C_G=$'\033[32m'
  C_Y=$'\033[33m'
  C_0=$'\033[0m'
else
  C_B=""
  C_D=""
  C_R=""
  C_G=""
  C_Y=""
  C_0=""
fi

# stderr の取り合い用。プロセス内で 1 個だけ作る。
# missing_of が毎回 mktemp すると、中断時に残骸が残る
NLP_STDERR="$(mktemp)"
# shellcheck disable=SC2064  # trap の中の変数は実行時に解決される (trap 登録時に展開させない)
trap 'rm -f "$NLP_STDERR"' EXIT

# エラー終了する。第 2 引数に終了コード (既定 1)
die() {
  printf '  %s%s%s\n' "$C_R" "$1" "$C_0" >&2
  exit "${2:-1}"
}

# 1行1個のテキストの行数。空文字なら 0
count_lines() { # <text>
  printf '%s' "$1" | grep -c . || true
}

# 標準入力の行数
count_stdin() {
  grep -c . || true
}

# 空白区切りのリストに要素が含まれるか
in_list() { # <要素> <リスト>
  local needle="$1" list="$2" item
  # shellcheck disable=SC2086  # 分割が目的 (リストは空白区切り)
  for item in $list; do
    if [ "$item" = "$needle" ]; then
      return 0
    fi
  done
  return 1
}
