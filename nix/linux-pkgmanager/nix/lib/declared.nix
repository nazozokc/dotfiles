# nix/lib/declared.nix
# 宣言 (packages/<pm>.nix / nlp.declared / lib.mkNlp の declared) の検査。
#
# 宣言の書き方は 2 種。
#
#   [ "man-db" "bash-completion" ]   インラインのリスト
#   ./packages/pacman.nix            ファイル (このリポジトリ自身と同じ形)
#
# ファイルはここで import してリストに直す。検査も焼き込みも
# 「リストだけ」を見ればよくなるので、以降の実装は入力形に依存しない
#
# なぜここで落とすのか
#   宣言は実行時のスクリプトに文字列として埋め込まれる。埋め込み自体は
#   単一引用符リテラルとして行うので、値の解釈は安全だ。ただしその値を
#   IFS で分割して pm の引数にするので、
#
#     - 空白を含む名前は 1 個が複数の引数に裂け、宣言件数も照合結果も嘘になる
#     - 制御文字や DEL を含む名前は出力と対比できなくなる
#
#   黙って直す実装 (空文字を落とす / 空白で分割する) は、
#   いちばん危ないのは「不足なし」に見えてしまうこと。だから評価時に落とす。
#
# ここで確かめるのは「形の正しさ」までで、pm がその名前を持っているかは見ない。
# 実在しない名前は apt の E: や pacman の終了コードで実行時に落とす
# (nix/lib/script/30-query.sh の query_failed)。
#
# 検査と throw を分ける理由
#   Nix 2.35 の builtins.tryEval は、throw したときのメッセージを読めない
#   (r.value を触ると同じ例外が再送出される)。 throw で検査すると
#   「落ちた」ことしか分からず、テストも 1 ケースごとに 1 プロセスになる。
#   そこで problems は「問題を文字列のリストで返す」だけの純関数にして、
#   validate がそれを throw に変換する。全部まとめて報告できるし、
#   テストは Nix 式の中でそのまま比較できる
{ lib, backends }:

let
  inherit (import ./names.nix) pattern hint;

  pms = lib.attrNames backends;

  # 宣言の値を「import 済みの中身」に直す。
  # パス (ファイル) なら import する。宣言の入力形の解釈はこの 1 箇所に閉じる
  inner = value: if lib.isPath value then import value else value;

  # 出所。エラーメッセージに出す
  #
  #   インライン → declared.pacman
  #   ファイル   → declared.pacman (/nix/store/...-source/packages/pacman.nix)
  #
  # 出所を持つのは、値だけを見ていると消費側の ./pkgs/pacman.nix で
  # 書いた名前が「packages/pacman.nix 由来」と誤って報告されるから。
  # このリポジトリ自身の packages/<pm>.nix と、消費側のファイルが同じ検査を通る
  origin =
    pm: value: if lib.isPath value then "declared.${pm} (${toString value})" else "declared.${pm}";

  # 宣言の値を「出所と値のリスト」に畳む
  #
  #   リスト → 1 個ずつ
  #   パス   → import した中身がリストなら 1 個ずつ、それ以外なら 1 件
  #
  # import は評価時に実行される (IFD)。ファイルが無い / 評価できないときは
  # Nix 自身のエラーがそのまま出る
  entriesOf =
    pm: value:
    let
      body = inner value;
      where = origin pm value;
      entry = v: {
        origin = where;
        value = v;
      };
    in
    if lib.isList body then map entry body else [ (entry body) ];

  # 宣言全体を「pm -> (出所と値のリスト)」に畳む。
  # attrset でなければ空を返す。形そのものは problems 側で報告する
  resolved = declared: if lib.isAttrs declared then lib.mapAttrs entriesOf declared else { };

  # 1 個の宣言の検査結果。問題が無ければ空リスト
  entryProblems =
    entry:
    let
      where = entry.origin;
      actual = lib.typeOf entry.value;
    in
    if !lib.isString entry.value then
      [
        ''
          nlp: ${where} の宣言は文字列で書いてください
          実際: ${actual}
        ''
      ]
    else if entry.value == "" then
      [
        ''
          nlp: ${where} の宣言に空文字列は書けません
          空の名前を黙って落とすと宣言件数が狂うので掉落させる
        ''
      ]
    else if !(builtins.match pattern entry.value != null) then
      [
        ''
          nlp: ${where} の宣言に pm が受理できないパッケージ名があります
          名前: "${entry.value}"
          使える文字: ${hint}
          注意: 空白・$・;・`・glob 文字を含む名前は、引数の区切りや
                shell の構文として解釈され照合結果が変わります
        ''
      ]
    else
      [ ];
in
rec {
  # 宣言全体の検査結果を文字列のリストで返す。throw はしない
  problems =
    declared:
    if !lib.isAttrs declared then
      [
        ''
          nlp: declared はパッケージマネージャーごとのリスト attrset で書いてください
          実際: ${lib.typeOf declared}
        ''
      ]
    else
      let
        names = lib.attrNames declared;

        # 未知の pm 名を黙って無視すると、その宣言は永遠に効かないまま
        # 「不足なし」と嘘をつく
        unknown = lib.filter (pm: !(lib.elem pm pms)) names;

        entries = resolved declared;

        # import した結果がリストでないもの。
        # 文字列をそのまま書いた (pacman = "man-db") や、
        # 中身がリストでないファイルもここに落ちる
        notList = lib.filter (pm: !(lib.isList (inner declared.${pm}))) names;

        # 要素まで見るのは「宣言されていて、かつ import 結果がリストである pm」だけ。
        # pms をそのまま回すと、宣言に無い pm で entries.${pm} が
        # 属性不存在になって落ちる
        listable = lib.filter (pm: !(lib.elem pm notList)) names;

        # 入れ子は 2 段: imap1 が「pm ごとのリスト」、その中身が
        # 「要素ごとのリスト」。lib.concatLists は 1 段しか平坦化しないので
        # 2 回呼ぶ。忘れると problems の要素がリストのまま残って、
        # 文字列として連結しようとしたところで落ちる
        listProblems = lib.concatLists (
          map (
            pm:
            lib.concatLists (
              lib.imap1 (idx: entry: (map (m: "  ${toString idx} 番目: ${m}") (entryProblems entry))) (
                entries.${pm} or [ ]
              )
            )
          ) listable
        );
      in
      (
        if unknown != [ ] then
          [
            ''
              nlp: 未知のパッケージマネージャー: ${lib.concatStringsSep ", " unknown}
              利用できるのは: ${lib.concatStringsSep ", " pms}
            ''
          ]
        else
          [ ]
      )
      ++ (
        if notList != [ ] then
          map (
            pm:
            let
              # notList に上がった pm は entries も必ず 1 件以上あるので head が取れる
              where = (lib.head (entries.${pm} or [ ])).origin;
              actual = lib.typeOf (inner declared.${pm});
            in
            ''
              nlp: ${where} の宣言はリストで書いてください
              実際: ${actual}
              リストでもファイルでも書けます:
                declared.${pm} = [ "man-db" ];
                declared.${pm} = ./packages/${pm}.nix;
            ''
          ) notList
        else
          [ ]
      )
      ++ listProblems;

  # 検査結果。normalized は宣言を pm ごとに揃えたもの
  # (書かなかった pm は空リスト。diff が「宣言なし」と出す)
  #
  # lib.mapAttrs ではなく lib.genAttrs pms を使う。
  # mapAttrs だと宣言が無い pm が落ちて、差分計算の前提が崩れる
  check =
    declared:
    let
      errs = problems declared;
      entries = resolved declared;
    in
    {
      ok = errs == [ ];
      errors = errs;
      normalized = lib.genAttrs pms (
        pm:
        # 重複は黙って 1 個に落とす。宣言件数の表示が狂うのを防ぐ。
        # ファイル指定の宣言も同じ扱いになる (値の比較だけを見るので)
        lib.unique (lib.map (e: e.value) (entries.${pm} or [ ]))
      );
    };

  # 検査して、問題があればまとめて throw する。
  # 問題がなければ正規化した宣言を返す
  #
  # 最後に deepSeq を通すのは、ファイル指定の宣言を import してから
  # 結果を組み立てるため。attrset を返しただけでは中身が未評価で、
  # import した中の throw や不正な値が後から漏れる
  validate =
    declared:
    let
      c = check declared;
    in
    if c.ok then
      builtins.deepSeq c.normalized c.normalized
    else
      throw (lib.concatStringsSep "\n" c.errors);
}
