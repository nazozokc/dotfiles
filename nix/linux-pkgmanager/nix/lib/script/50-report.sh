# shellcheck shell=bash
# nix/lib/script/50-report.sh — 表示の整形だけ
#
# 責務は「読むための形にする」ことだけ。
# 値を作る (照合・宣言) は 30-query.sh の仕事。
#
# 色エスケープを printf の書式の中に混ぜると幅計算が壊れるので、
# 整形は全部済ませてから色を付ける

# リストを表示する。 limit を超えた分は「... 他 n 個」で畳む
print_list() { # <limit> <body>
  local limit="$1" body="$2" n
  n="$(count_lines "$body")"
  [ "$n" -gt 0 ] || return 0
  if [ "$n" -gt "$limit" ]; then
    printf '%s\n' "$body" | head -n "$limit" | sed 's/^/    - /'
    printf '    %s... 他 %s 個%s\n' "$C_D" "$((n - limit))" "$C_0"
  else
    printf '%s\n' "$body" | sed 's/^/    - /'
  fi
}

# argv を 1 本のコマンドとして提示する
print_cmd() { # <argv...>
  printf '  %ssudo%s' "$C_D" "$C_0"
  printf ' %s' "$@"
  printf '\n'
}
