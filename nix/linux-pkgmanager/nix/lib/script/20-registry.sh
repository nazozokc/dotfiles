# shellcheck shell=bash
# nix/lib/script/20-registry.sh — backend 定義と宣言 (nix が埋め込む静的な値)
#
# このファイルの責務は「データを受け取る器」だけ。
# 値の生成 (backend 定義 / 宣言の検証) は nix 側にある。
#
# すべての値は bash の単一引用符リテラルとして埋め込まれる
# (nix/lib/render.nix の bashQuote)。
# 引用符の中では変数展開もコマンド置換も起きないため、
# 宣言やコマンドに $ や空白や改行が混ざっても「値」として保たれる。
#
#   PM_LABEL            表示名
#   PM_BINARY           存在判定に使う実行ファイル名
#   PM_LOCK             排他ロックファイル (status の表示用)
#   PM_EXPLICIT         明示導入されたパッケージを1行1個で出すコマンド
#   PM_MISSING          不足判定コマンド (@PKGS@ が宣言列の位置を示す)
#   PM_MISSING_PARSE    判定出力からパッケージ名を抜く sed スクリプト
#   PM_MISSING_OUTPUT   missing = 不足名を出す / satisfied = 充足名を出す
#   PM_MISSING_OK       「有効な答え」を表す終了コード (空白区切り)
#   PM_MISSING_ERROR    stderr に現れたら異常とみなすパターン (1行1個)
#   PM_INSTALL          導入コマンド (@PKGS@ が宣言列の位置を示す)
#   PM_UPDATE           更新コマンド (1行1個。sudo を個別に付けるため)
#   PM_NAME_PATTERN     pm が受理するパッケージ名の形 (nix/lib/names.nix)
#   PM_NAME_HINT        その規則の説明。adopt が除外した名前を説明するときに使う
#   DECLARED            宣言 (1行1個)

# このファイルは「器」だけで、読むのは連結後のスクリプト側。
# 単体で lint すると全部の配列が「使われていない」と出るので SC2034 を黙る。
# 連結後のスクリプトで実際に使われていない変数は writeShellApplication が見る
# shellcheck disable=SC2034

declare -A PM_LABEL PM_BINARY PM_LOCK PM_EXPLICIT
declare -A PM_MISSING PM_MISSING_PARSE PM_MISSING_OUTPUT
declare -A PM_MISSING_OK PM_MISSING_ERROR PM_INSTALL PM_UPDATE DECLARED

@@REGISTRY@@
