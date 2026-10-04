# shellcheck shell=bash
# nix/lib/script/90-main.sh — 入口
#
# 責務は「引数を解釈して、どのサブコマンドに渡すか」だけ。
#
# app ラッパー (nix/lib/apps.nix) は第 1 引数にコマンド名を固定する。
# そのため第 1 引数が空のときは diff 扱いになる。
# `nix run .#diff -- --help` のように後ろに付いたフラグも受け取る

usage() {
  cat <<'USAGE'
linux-pkgmanager.nix — 宣言的に Linux のパッケージマネージャーを扱う

usage: nix run .#<command>

  diff     宣言と導入済みを比較する (default / 副作用なし)
  adopt    明示導入済みを宣言の雛形として出す (副作用なし)
  apply    不足しているパッケージを導入する
  update   パッケージマネージャーを更新してから不足分を補う
  status   検出したパッケージマネージャーと宣言の件数

adopt は標準出力に宣言そのものだけを出します。人が読む行は標準エラーです。

  nix run .#adopt > packages/pacman.nix
USAGE
}

main() {
  local cmd="${1:-diff}"
  local pm arg

  if [ "$#" -gt 0 ]; then
    shift
  fi

  case "$cmd" in
  diff | apply | update | status | adopt) ;;
  -h | --help | help)
    usage
    return 0
    ;;
  *)
    printf '  %sunknown command%s: %s\n\n' "$C_R" "$C_0" "$cmd" >&2
    usage >&2
    return 2
    ;;
  esac

  # 補助フラグはどこに付いたものでも受理する。
  # それ以外の引数は「打った覚えのない引数」なので落とす
  for arg in "$@"; do
    case "$arg" in
    -h | --help | help)
      usage
      return 0
      ;;
    *)
      printf '  %sunexpected argument%s: %s\n\n' "$C_R" "$C_0" "$arg" >&2
      usage >&2
      return 2
      ;;
    esac
  done

  if ! pm="$(detect_pm)"; then
    printf '  %s%s を確認できるパッケージマネージャーがありません%s\n' \
      "$C_R" "${PM_ORDER[*]}" "$C_0" >&2
    return 1
  fi

  # adopt は標準出力が宣言そのものになる。人が読む行をここへ混ぜると
  # `nlp adopt > packages/<pm>.nix` が壊れるので、この行だけ出さない
  case "$cmd" in
  adopt) ;;
  *)
    printf '  %s%s · %s · %s%s\n' "$C_D" "$cmd" "$(host_id)" "${PM_LABEL[$pm]}" "$C_0"
    ;;
  esac

  case "$cmd" in
  diff) do_diff "$pm" ;;
  adopt) do_adopt "$pm" ;;
  apply) do_apply "$pm" ;;
  update) do_update "$pm" ;;
  status) do_status "$pm" ;;
  esac
}

main "$@"
