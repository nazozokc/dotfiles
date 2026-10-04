# shellcheck shell=bash
# nix/lib/script/30-query.sh — 宣言と導入済みの照合 (pm に依存しない)
#
# 責務は 3 つに閉じている。
#   declared_of / explicit_of / missing_of : 一覧を出す
#   run_query                              : コマンド文字列を argv にして実行
#   lines_to_argv                          : 一覧を argv にする
#
# pm ごとの差分は nix/lib/backends.nix に閉じている。
# このファイルは pm 名を知らない。
#
# 引数を 1 個ずつ保つのはこのファイルの肝。
# パッケージ名を空白区切りの文字列に畳んでから IFS で割ると、
# 空白を含む名前が複数の引数に裂ける。裂けた引数は pm に別の名前として
# 渡るので照合結果そのものが嘘になる。よって「宣言 → argv」の経路では
# 改行で切って 1 個ずつの要素にする

# 1行1個のテキストを argv にする。
# NUL 区切りで返すので、呼び出し側は
#   mapfile -d '' -t arr < <(lines_to_argv "$text")
# でそのまま argv として受け取れる。空白ではなく改行で切るので、
# 空白を含む名前も 1 個の引数として保たれる
lines_to_argv() { # <text>
  local line
  [ -n "${1:-}" ] || return 0
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    printf '%s\0' "$line"
  done <<<"$1"
}

# 宣言を 1行1個・ソート済みで出す
declared_of() {
  local s="${DECLARED[$1]}"
  [ -n "$s" ] || return 0
  printf '%s\n' "$s" | sed '/^[[:space:]]*$/d' | sort -u
}

# 空白区切りのコマンド文字列を argv に分解して実行する。
# 第 2 引数以降は「そのまま 1 個ずつ」引数として足す。
#
# eval を使わないのが要点。eval だと `rpm --qf '%{NAME}\n'` の
# ${NAME} が空の変数として展開され、`%{NAME}` が `%` だけになる
# (dnf / zypper / yum の照合が全部壊れる)。
# また eval は宣言に書かれた文字列から任意コマンドを走らせる余地になるため、
# ここでは一切使わない
run_query() { # <command string> [arg ...]
  local -a argv=()
  read -ra argv <<<"${1:-}"
  shift || true
  [ "${#argv[@]}" -gt 0 ] || return 0
  argv+=("$@")
  "${argv[@]}"
}

# 明示的に導入されたパッケージを 1行1個・ソート済みで出す
# (依存として入ったものは含めない)
explicit_of() {
  run_query "${PM_EXPLICIT[$1]}" 2>/dev/null | sed '/^[[:space:]]*$/d' | sort -u
}

# 照合コマンドが「有効な答えを出した」かどうか
#
# backend ごとに 2 つの情報で判定する。
#
#   okCodes : 有効な答えに対応する終了コード。
#             pacman -T は不足があると 127、rpm -q は 1 で終わる。
#             これを「異常」と見なすと不足があるだけで常に異常終了になる
#   error   : stderr に現れたら異常とみなすパターン。
#             全部の `error:` を見てはいけない。pacman は不足があるだけで
#             `error: package 'x' was not found` のような行を stderr に
#             出すため、そのまますると不足があるだけで全景が落ちる
query_failed() { # <pm> <rc> <stderr-file>
  local pm="$1" rc="$2" err="$3" pattern

  if in_list "$rc" "${PM_MISSING_OK[$pm]}"; then
    :
  else
    return 0
  fi

  while IFS= read -r pattern; do
    [ -n "$pattern" ] || continue
    if grep -qE -- "$pattern" "$err"; then
      return 0
    fi
  done <<<"${PM_MISSING_ERROR[$pm]}"

  return 1
}

# 不足パッケージを 1行1個・ソート済みで出す
#
# 照合コマンドの答えが壊れているときは終了コード 2 で落とす。
# この判定が無いと、宣言に存在しないパッケージ名が 1 つ混ざっただけで
# apt が E: を吐いて異常終了し、Inst 行が 1 行も出ないまま
# 「不足なし」に見えてしまう (偽陰性)
missing_of() { # <pm>
  local pm="$1" cmd raw rc parsed
  local -a names=()

  # @PKGS@ は引数列の位置を示すマーカー。落として宣言を足す
  cmd="${PM_MISSING[$pm]//@PKGS@/}"
  mapfile -d '' -t names < <(lines_to_argv "$(declared_of "$pm")")

  : >"$NLP_STDERR"
  # 異常終了は query_failed が判定するので、ここでは握り潰さない
  if raw="$(run_query "$cmd" ${names[@]+"${names[@]}"} 2>"$NLP_STDERR")"; then
    rc=0
  else
    rc=$?
  fi

  if query_failed "$pm" "$rc" "$NLP_STDERR"; then
    printf '\n  %s%s: 照合コマンドが異常です (rc=%s)%s\n' "$C_R" "$pm" "$rc" "$C_0" >&2
    printf '  %s宣言に実在しないパッケージ名があるか、pm が実行できない状態%s\n' \
      "$C_D" "$C_0" >&2
    sed 's/^/    /' "$NLP_STDERR" >&2
    return 2
  fi

  parsed="$(
    printf '%s\n' "$raw" |
      sed -n "${PM_MISSING_PARSE[$pm]}p" |
      sed '/^[[:space:]]*$/d' |
      sort -u
  )"

  case "${PM_MISSING_OUTPUT[$pm]}" in
  satisfied)
    # 充足名を引くと不足名になる。充足名が空なら宣言全体が不足
    if [ -z "$parsed" ]; then
      declared_of "$pm"
      return 0
    fi
    comm -23 <(declared_of "$pm") <(printf '%s\n' "$parsed")
    ;;
  *)
    printf '%s\n' "$parsed"
    ;;
  esac
}
