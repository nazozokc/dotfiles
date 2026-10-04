# shellcheck shell=bash
# nix/lib/script/60-commands.sh — サブコマンドの実装
#
# 責務は「どのサブコマンドが何をするか」だけ。
# 照合は 30-query.sh、pm データは 20-registry.sh、整形は 50-report.sh。
#
# 副作用の分類 (README のコマンド表と同じ)
#   なし   diff / status / adopt
#   あり   apply / update
#
# adopt だけは標準出力が「データ」(宣言そのもの) になる。
# 人が読む行はすべて標準エラーへ出す前提で書いている
#
# root 権限の扱い
#   ここが root 実行の唯一の場所。sudo がないときに素のコマンドへ
#   フォールバックしない。黙って非 root で入れるほうが事故になるため、
#   足りないならそのまま落とす

# パスワード入力を 1 回にまとめる。先に成否を確認してから本体に進む
sudo_prelude() {
  if ! command -v sudo >/dev/null 2>&1; then
    die "sudo が見つかりません。root で実行するコマンドには使えません" 1
  fi
  sudo -v || die "sudo の認証に失敗しました" 1
}

# root で 1 本のコマンドを実行する
run_root() { # <argv...>
  sudo "$@"
}

# install コマンドのテンプレートを argv に展開する (NUL 区切りで返す)。
# テンプレート中の @PKGS@ を、パッケージ名を並べた列に差し替える。
#
# 文字列として置換してから再度分割する実装は使わない。
# パッケージ名に空白や glob が混ざると引数がズレ、
# どこかで eval を使う羽目になれば任意コマンドが走るため、
# argv のまま組み立てて NUL 区切りで返す
install_argv() { # <template> <package>...
  local -a tmpl=()
  local token

  read -ra tmpl <<<"${1:-}"
  shift || true
  [ "${#tmpl[@]}" -gt 0 ] || return 1

  for token in "${tmpl[@]}"; do
    if [ "$token" = "@PKGS@" ]; then
      if [ "$#" -gt 0 ]; then
        printf '%s\0' "$@"
      fi
    else
      printf '%s\0' "$token"
    fi
  done
}

# 不足分を数えて表示する
print_counts() { # <missing> <installed> <unmanaged>
  local missing="$1" installed="$2" unmanaged="$3"

  printf '  installed %s%3d%s\n' "$C_D" "$installed" "$C_0"
  printf '  missing   %s%3d%s\n' \
    "$([ -n "$missing" ] && printf '%s' "$C_Y" || printf '%s' "$C_G")" \
    "$(count_lines "$missing")" "$C_0"
  print_list 20 "$missing"

  printf '  unmanaged %s%3d%s  %s宣言に無いが明示導入済み%s\n' \
    "$C_D" "$(count_lines "$unmanaged")" "$C_0" "$C_D" "$C_0"
  print_list 10 "$unmanaged"
  printf '\n'
}

# 宣言と導入済みを比較する (副作用なし)
do_diff() { # <pm>
  local pm="$1"
  local missing unmanaged installed n_declared

  if [ -z "${DECLARED[$pm]}" ]; then
    printf '  %s%s は宣言なし%s (packages/%s.nix)\n' "$C_Y" "$pm" "$C_0" "$pm"
    return 0
  fi

  missing="$(missing_of "$pm")" || return 2
  unmanaged="$(comm -13 <(declared_of "$pm") <(explicit_of "$pm"))"
  n_declared="$(count_lines "$(declared_of "$pm")")"
  # 不足名は宣言の要素なので、宣言との交集を数える。
  # 単純に引き算すると、判定が壊れたときに負の installed が出る
  # installed = 宣言 - 不足 (集合差)。
  # 引き算ではなく集合差で数える。判定が壊れたときに負の installed が出ない
  installed="$(comm -23 <(declared_of "$pm") <(printf '%s\n' "$missing") | count_stdin)"

  printf '\n  %shost%s     %s (%s) %s· %s 宣言%s\n' "$C_B" "$C_0" "$(host_id)" \
    "${PM_LABEL[$pm]}" "$C_D" "$n_declared" "$C_0"
  printf '\n'
  print_counts "$missing" "$installed" "$unmanaged"
}

# 明示導入済みパッケージを、宣言の雛形として標準出力に出す (副作用なし)
#
# ファイルは書かない。nlp が壊すものはない (pm が導入済みを所有している) ので
# 破壊する経路も opt-in も必要ない。nix-homebrew の autoMigrate は
# 「既存を消して宣言に置き換える」ために確認を要求したが、
# ここでは読み取るだけなので確認の段階が存在しない
#
# 標準出力は「宣言そのもの」だけにする。人が読む行はすべて標準エラーへ出す。
# ここへ 1 行でも混ざると `nlp adopt > packages/<pm>.nix` が壊れたファイルになる
#
# 照会が失敗したら空のリストは出さない。空の [ ] は「導入済み 0 件」という
# 宣言になり、diff が常に「不足なし」になる。壊れた答えをそのまま書くと
# 嘘が宣言に焼き付くので、終了コード 2 で止まる
do_adopt() { # <pm>
  local pm="$1" raw rc kept dropped query n_declared

  : >"$NLP_STDERR"
  if raw="$(run_query "${PM_EXPLICIT[$pm]}" 2>"$NLP_STDERR")"; then
    rc=0
  else
    rc=$?
  fi

  if [ "$rc" -ne 0 ]; then
    printf '  %s%s: 明示導入の照会が失敗しました (rc=%s)%s\n' "$C_R" "$pm" "$rc" "$C_0" >&2
    printf '  %s空のリストは「導入済み 0 件」という宣言になるので作りません%s\n' \
      "$C_D" "$C_0" >&2
    sed 's/^/    /' "$NLP_STDERR" >&2
    return 2
  fi

  # 宣言検査と同じ形を通す (PM_NAME_PATTERN は nix/lib/names.nix)。
  # 落ちた名前は黙って捨てない。黙って捨てると「宣言に無い」のが
  # 「除外した結果」なのか「元から無かった」のか区別できなくなる
  kept="$(printf '%s\n' "$raw" | sed '/^[[:space:]]*$/d' | grep -E "$PM_NAME_PATTERN" || true)"
  dropped="$(printf '%s\n' "$raw" | sed '/^[[:space:]]*$/d' | grep -vE "$PM_NAME_PATTERN" || true)"
  kept="$(printf '%s\n' "$kept" | sort -u)"
  dropped="$(printf '%s\n' "$dropped" | sort -u)"

  if [ -n "$dropped" ]; then
    printf '  %s%s: pm が受理できないパッケージ名を宣言から外しました%s\n' \
      "$C_Y" "$pm" "$C_0" >&2
    print_list 20 "$dropped" >&2
    printf '  %s使える文字: %s%s\n' "$C_D" "$PM_NAME_HINT" "$C_0" >&2
  fi

  if [ -z "$kept" ]; then
    printf '  %s%s: 明示導入済みが 1 個も返りませんでした%s\n' "$C_Y" "$pm" "$C_0" >&2
    printf '  %s空の宣言を生成します。pm が動いているか確認してください%s\n' "$C_D" "$C_0" >&2
  fi

  # 出力は「導入済み全部」のスナップショットで、既存宣言への差分ではない。
  # 黙って上書きさせないために、宣言があるときは先に言っておく
  n_declared="$(count_lines "$(declared_of "$pm")")"
  if [ "$n_declared" -gt 0 ]; then
    printf '  %s注意%s  %s には既に %s 件の宣言があります。adopt は導入済み全部を出します\n' \
      "$C_Y" "$C_0" "$pm" "$n_declared" >&2
    printf '  %s上書きせず、既存宣言と共通する名前を消してから使ってください%s\n' \
      "$C_D" "$C_0" >&2
  fi

  # 照合コマンド。@PKGS@ を宣言に置き換えた位置だけ削って、
  # 生成したファイルのコメントに実際の照合方法を書く
  query="${PM_MISSING[$pm]//@PKGS@/}"
  query="${query# }"
  query="${query% }"

  printf '# packages/%s.nix — %s で導入するパッケージ\n' "$pm" "$pm"
  printf '#\n'
  printf '# nlp adopt が生成しました (ホスト: %s)。\n' "$(host_id)"
  printf '# 明示導入済みパッケージをそのまま列挙しています。\n'
  printf '#\n'
  printf '# ここに書くのは「システムのリソース」だけ。\n'
  printf '#   - /etc の設定、/usr/share/man の man page\n'
  printf '#   - systemd unit、カーネルモジュール、firmware\n'
  printf '# 逆に、ユーザーの製品 (エディタ、言語ランタイム、CLI ツール) は\n'
  printf '# Nix (home-manager の home.packages) 経由で入れる。ここには書かない。\n'
  printf '# 二重管理になり、片方だけ古いと事故る。\n'
  printf '#\n'
  printf '# 宣言から外したパッケージは削除されません。unmanaged として\n'
  printf '# 報告されるだけで、何もしません。\n'
  printf '#\n'
  # backtick を書くと lint が SC2016 を出すので printf の \x60 で出す。
  # 生成する Nix のコメントは packages/<pm>.nix に倣って `cmd` で囲む
  printf '# 照合は \x60%s\x60 で行います。\n' "$query"
  printf '\n'
  printf '[\n'
  if [ -n "$kept" ]; then
    # namePattern が " を弾いているので、引用符で囲むだけで Nix の文字列になる。
    # 行全体を置換する形にしてあるのは、末尾に $ アンカーを書くと
    # lint が SC2016 (単一引用符 = 展開されない) を出すため
    printf '%s\n' "$kept" | sed 's/.*/  "&"/'
  fi
  printf ']\n'
}

# 不足分を導入する
do_apply() { # <pm>
  local pm="$1" missing
  local -a argv=() names=()

  missing="$(missing_of "$pm")" || return 2

  if [ -z "$missing" ]; then
    printf '  %s不足なし%s (何もしません)\n' "$C_G" "$C_0"
    return 0
  fi

  # 不足名を「1 個 = 1 引数」で install の argv に組み立てる。
  # 空白区切りの文字列に畳むと空白を含む名前が裂ける
  mapfile -d '' -t names < <(lines_to_argv "$missing")
  mapfile -d '' -t argv < <(install_argv "${PM_INSTALL[$pm]}" ${names[@]+"${names[@]}"})
  if [ "${#argv[@]}" -eq 0 ]; then
    die "$pm の install コマンドを生成できません" 1
  fi

  printf '  %s導入%s\n' "$C_B" "$C_0"
  print_list 50 "$missing"
  print_cmd "${argv[@]}"

  sudo_prelude
  run_root "${argv[@]}"
}

# pm 自身を更新してから不足分を補う
#
# update は 1 コマンドずつ sudo を付ける。
# `&&` で 1 本に繋いで sudo を前置すると、2 本目以降が root でないまま走る
do_update() { # <pm>
  local pm="$1" line
  local -a argv=()

  sudo_prelude

  while IFS= read -r line; do
    [ -n "$line" ] || continue
    read -ra argv <<<"$line"
    [ "${#argv[@]}" -gt 0 ] || continue
    printf '  %supdate%s  ' "$C_B" "$C_0"
    print_cmd "${argv[@]}"
    run_root "${argv[@]}"
  done <<<"${PM_UPDATE[$pm]}"

  printf '\n'
  do_apply "$pm"
}

# 検出結果と宣言の件数だけを報告する (副作用なし)
#
# binary 列は `pacman@/usr/bin/pacman` のようにパスが入るため、
# 列幅は表示前に実測して決める
do_status() { # <pm>
  local pm binary declared_count lock_state col w=8 i=0
  local -a binaries=() founds=()

  # 表示の前に binary 列の幅を決める。`pacman@/usr/bin/pacman` のように
  # パスが入るので、固定幅では pm によって桁がずれる
  for pm in "${PM_ORDER[@]}"; do
    if command -v "${PM_BINARY[$pm]}" >/dev/null 2>&1; then
      binaries+=("${PM_BINARY[$pm]}@$(command -v "${PM_BINARY[$pm]}")")
      founds+=("yes")
    else
      binaries+=("(not found)")
      founds+=("no")
    fi
    if [ "${#binaries[-1]}" -gt "$w" ]; then
      w="${#binaries[-1]}"
    fi
  done

  printf '\n  %spm%s       %sbinary%s%*s  %sdeclared%s  %slock%s\n' \
    "$C_B" "$C_0" "$C_D" "$C_0" $((w - 8)) "" "$C_D" "$C_0" "$C_D" "$C_0"

  for pm in "${PM_ORDER[@]}"; do
    binary="${binaries[$i]}"
    declared_count="$(count_lines "$(declared_of "$pm")")"

    if [ "${founds[$i]}" = "yes" ]; then
      col="$C_G"
      if [ -e "${PM_LOCK[$pm]}" ]; then
        lock_state="$C_Y held$C_0"
      else
        lock_state="free"
      fi
    else
      col="$C_D"
      lock_state="$C_D-$C_0"
    fi
    i=$((i + 1))

    printf '    %s%-9s%s %-*s %8s  %s\n' \
      "$col" "$pm" "$C_0" "$w" "$binary" "$declared_count" "$lock_state"
  done
  printf '\n'
}
