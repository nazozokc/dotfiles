# tests/eval/cases.nix
# 宣言の検査 (nix/lib/declared.nix) を評価時に試すケース一覧。
#
# ここは「Nix の式」なのでビルドも nix eval も走らない。
# 各ケースは検査関数をその場で 1 回呼んだ結果だけを持ち、
# チェック側 (nix/flake-parts/checks.nix) が PASS / FAIL の文字列を比べる。
#
# 「落ちた」だけでなく「期待する文言が入っている」ことも見る。
# 単に落ちただけだと、何で落ちたのか分からなくなる
#
# throw ではなく problems (pure な検査) を使う理由
#   Nix 2.35 の builtins.tryEval は throw のメッセージを読めない。
#   r.value を触ると同じ例外が再送出されるので、
#   「落ちた」ことしか分からない。problems なら文言までそのまま取れる
{ lib, check }:

let
  # 1 つの宣言を試す。検査は純粋関数なのでその場で呼べる
  attempt =
    c:
    let
      name = builtins.elemAt c 0;
      declared = builtins.elemAt c 1;
      r = check declared;
    in
    {
      inherit name;
      # 検査を「通った」かどうか
      accepted = r.ok;
      # メッセージは多行。差分を読みやすくするため 1 行に潰す
      detail = if r.ok then "受理" else lib.concatStringsSep " / " r.errors;
    };

  # 受理されてよい宣言。
  # 1 ケース = 1 引数の lambda にしておく。
  # 「2 引数の lambda」を map に食わせると部分適用になって、
  # 要素が関数のまま残るので
  # 「expected a set but found a function」で落ちる
  accepts =
    c:
    let
      a = attempt c;
    in
    {
      inherit (a) name;
      ok = a.accepted;
      inherit (a) detail;
    };

  # 受理されてはいけない宣言。
  # 却下され、さらに needle がメッセージに入っていれば合格
  rejects =
    c:
    let
      name = builtins.elemAt c 0;
      needle = builtins.elemAt c 1;
      a = attempt [
        name
        (builtins.elemAt c 2)
      ];
    in
    {
      name = "${a.name} -> ${needle}";
      ok = !a.accepted && lib.hasInfix needle a.detail;
      detail = if a.accepted then "受理された (期待は却下)" else a.detail;
    };

  # import された値をそのまま比べるケース。
  # 「受理された」だけでは「ファイルの中身が入っている」ことを保証できない
  #
  # 宣言は { <pm> = [ ... ]; } の形で書くと、期待値はその pm だけを見る
  values =
    c:
    let
      name = builtins.elemAt c 0;
      declared = builtins.elemAt c 1;
      expected = builtins.elemAt c 2;
      inherit ((check declared)) normalized;

      # 宣言していない pm は比較しない (必ず空リストになる)
      picked = lib.filterAttrs (pm: _: lib.hasAttr pm expected) normalized;

      show =
        a: lib.concatStringsSep " " (lib.mapAttrsToList (pm: v: "${pm}=[${lib.concatStringsSep " " v}]") a);
    in
    {
      inherit name;
      ok = picked == expected;
      detail = "期待: ${show expected} / 実際: ${show picked}";
    };

  all =
    map accepts [
      [
        "空の宣言"
        { }
      ]
      [
        "pacman だけ"
        {
          pacman = [
            "man-db"
            "bash-completion"
          ];
        }
      ]
      [
        "複数 pm"
        {
          pacman = [ "man-db" ];
          apt = [ "bat" ];
        }
      ]
      [
        "ファイルの宣言 (import)"
        {
          pacman = ./fixtures/list-ok.nix;
        }
      ]
      [
        "重複は 1 個に落ちる"
        {
          pacman = [
            "man-db"
            "man-db"
          ];
        }
      ]
      [
        "記号を含む名前"
        {
          dnf = [
            "gcc-c++"
            "python3.11"
            "lib32-gtk3"
            "nvidia-550xx-dkms"
            "java-17-openjdk"
            "perl-Foo_bar"
          ];
        }
      ]
    ]
    ++ map rejects [
      [
        "未知の pm"
        "未知のパッケージマネージャー"
        { apk = [ "bash" ]; }
      ]
      [
        "リストでない宣言"
        "リストで書いてください"
        { pacman = "man-db"; }
      ]
      [
        "attrset の宣言"
        "リストで書いてください"
        {
          pacman = {
            a = 1;
          };
        }
      ]
      [
        "文字列でない要素"
        "文字列で書いてください"
        { pacman = [ 42 ]; }
      ]
      [
        "空文字列"
        "空文字列"
        { pacman = [ "" ]; }
      ]
      [
        "空白を含む名前"
        "受理できない"
        { pacman = [ "foo bar" ]; }
      ]
      [
        "コマンド置換を含む名前"
        "受理できない"
        { pacman = [ "x$(id)" ]; }
      ]
      [
        "セミコロンを含む名前"
        "受理できない"
        { pacman = [ "ripgrep; rm -rf /" ]; }
      ]
      [
        "バッククォートを含む名前"
        "受理できない"
        { pacman = [ "x`id`" ]; }
      ]
      [
        "改行を含む名前"
        "受理できない"
        { pacman = [ "foo\nbar" ]; }
      ]
      [
        "タブを含む名前"
        "受理できない"
        { pacman = [ "foo\tbar" ]; }
      ]
      [
        "先頭がハイフン"
        "受理できない"
        { pacman = [ "-rf" ]; }
      ]
      [
        "glob 文字を含む名前"
        "受理できない"
        { pacman = [ "*" ]; }
      ]
      [
        "attrset でない declared"
        "attrset"
        [ "man-db" ]
      ]

      # ファイル指定 (import) の却下ケース。
      # 「リストでない宣言」のメッセージがファイル指定でも出ること、
      # ファイルの中の不正な名前には出所が出ることを確認する
      [
        "import 結果がリストでない"
        "リストで書いてください"
        { pacman = ./fixtures/not-list.nix; }
      ]
      [
        "ファイルの中の不正な名前"
        "fixtures/bad-name.nix"
        { pacman = ./fixtures/bad-name.nix; }
      ]
      [
        "ファイル指定でも受理できない名前"
        "受理できない"
        { pacman = ./fixtures/bad-name.nix; }
      ]
    ]
    ++ map values [
      [
        "ファイルの宣言を import する"
        { pacman = ./fixtures/list-ok.nix; }
        {
          pacman = [
            "man-db"
            "bash-completion"
          ];
        }
      ]
      [
        "パスとインラインが混ざ어도よい"
        {
          pacman = ./fixtures/list-ok.nix;
          apt = [ "bat" ];
        }
        {
          pacman = [
            "man-db"
            "bash-completion"
          ];
          apt = [ "bat" ];
        }
      ]
      [
        "ファイルの重複も 1 個に落ちる"
        { pacman = ./fixtures/list-dup.nix; }
        { pacman = [ "man-db" ]; }
      ]
    ];

  # 集計は let に置く。
  # 戻す attrset は関数 ({ lib, validate }: ...) なので rec ではなく、
  # 同じ attrset の中の値 (passed など) を別の属性から参照できない
  passed = builtins.length (builtins.filter (c: c.ok) all);
  total = builtins.length all;
in
{
  inherit
    all
    passed
    total
    ;

  # checks.nix がそのまま cat できる 1 本のレポート
  report = lib.concatMapStringsSep "\n" (
    c: (if c.ok then "PASS " else "FAIL ") + c.name + (if c.ok then "" else " / " + c.detail)
  ) all;

  summary = "declared eval: ${toString passed} / ${toString total} ケース";
}
