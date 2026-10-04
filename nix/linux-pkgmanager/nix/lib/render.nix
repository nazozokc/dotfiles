# nix/lib/render.nix
# 宣言 (packages/*.nix) + backend 定義 (nix/lib/backends.nix) から
# 実行する bash を1本の文字列として組み立てる。
#
# このファイルの責務は「組み立て」だけ:
#   - nix/lib/script/*.sh を順番に連結する (各ファイルが1つの責務を持つ)
#   - 20-registry.sh の @@REGISTRY@@ を backend 定義と宣言で埋める
#   - backend / 宣言の値を bash の単一引用符リテラルへ変換する
#
# ここに置いていないもの (意図的)
#   - 照合ロジック、表示、コマンドの実装 → nix/lib/script/*.sh
#   - 宣言の検証 → nix/lib/declared.nix
#
# 純評価について
#   宣言も backend も Nix の値なので `nix eval` / `nix flake check` は
#   pure 評価のまま通る。導入済み一覧を Nix 側で読むと `builtins.readFile` が
#   必要になり pure 評価が壊れるため、照合は実行時スクリプトに置く。
#   このファイルが読むのは「_inputs_ されたスクリプトのソース」だけなので
#   store の内容と結びついていて pure 評価は壊れない。
#
# 値のエスケープについて
#   すべての値を bash の単一引用符リテラルとして埋め込む。
#   引用符の中では変数展開もコマンド置換も起きないので、
#   宣言やコマンドに $ や空白や改行が混ざっても「値」として保たれる。
#   つまり exec 的な埋め込み (eval やダブルクォート) はこのファイルに無い。
{
  lib,
  backends,
  declared,
}:

let
  # 生成の順序がそのままスクリプトの並びになる
  scriptFiles = [
    "10-runtime.sh"
    "20-registry.sh"
    "30-query.sh"
    "40-detect.sh"
    "50-report.sh"
    "60-commands.sh"
    "90-main.sh"
  ];

  readScript = name: builtins.readFile ./script/${name};

  # bash の単一引用符リテラル。内部の ' だけ '\'' に逃がす
  bashQuote = s: "'${lib.replaceStrings [ "'" ] [ "'\\''" ] s}'";

  # 宣言を重複なしにする。sort は実行時クエリと並びを揃えるためここではしない
  declaredList = pm: lib.sort (a: b: a < b) (declared.${pm} or [ ]);

  # backend 1 件 -> レジストリの代入
  renderBackend =
    pm:
    let
      b = backends.${pm};
      q = b.missingQuery;
    in
    lib.concatStringsSep "\n" [
      "PM_LABEL[${pm}]=${bashQuote b.label}"
      "PM_BINARY[${pm}]=${bashQuote b.binary}"
      "PM_LOCK[${pm}]=${bashQuote b.lock}"
      "PM_EXPLICIT[${pm}]=${bashQuote b.explicit}"
      "PM_MISSING[${pm}]=${bashQuote (q.cmd "@PKGS@")}"
      "PM_MISSING_PARSE[${pm}]=${bashQuote q.extract}"
      "PM_MISSING_OUTPUT[${pm}]=${bashQuote q.output}"
      "PM_MISSING_OK[${pm}]=${bashQuote (lib.concatMapStringsSep " " toString q.okCodes)}"
      "PM_MISSING_ERROR[${pm}]=${bashQuote (lib.concatStringsSep "\n" q.error)}"
      "PM_INSTALL[${pm}]=${bashQuote (b.install "@PKGS@")}"
      "PM_UPDATE[${pm}]=${bashQuote (lib.concatStringsSep "\n" b.update)}"
      "DECLARED[${pm}]=${bashQuote (lib.concatStringsSep "\n" (declaredList pm))}"
    ];

  pmNames = lib.attrNames backends;

  # pm に依らない共通値。宣言検査 (nix/lib/declared.nix) と同じ定義を
  # 実行時にも渡さないと、adopt が「評価時に落ちる宣言」を生成してしまう
  common = import ./names.nix;

  # 1 エントリ = 1 backend の代入ブロック。backend 間は空行で区切る
  registry = lib.concatStringsSep "\n" [
    "PM_ORDER=(${lib.concatMapStringsSep " " bashQuote pmNames})"
    "PM_NAME_PATTERN=${bashQuote common.pattern}"
    "PM_NAME_HINT=${bashQuote common.hint}"
    ""
    (lib.concatMapStringsSep "\n" renderBackend pmNames)
  ];

  assemble = name: lib.replaceStrings [ "@@REGISTRY@@" ] [ registry ] (readScript name);
in

# 連結するだけ。値は渡されたままの文字列
lib.concatStringsSep "\n" (map assemble scriptFiles)
