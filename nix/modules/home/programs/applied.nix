# nix/modules/home/programs/applied.nix
#
# programs/ 配下の各モジュールが「この config は適用された」ことを宣言し、
# home-manager の activation で一覧表示する仕組み。
#
# 使い方は各プログラムモジュール側で 1 エントリ書くだけ:
#
#   dotfiles.programs.bat = {
#     icon = "🦇";
#     note = "TwoDark / less pager";
#   };
#
# 設計:
#   - 並びは名前昇順で固定する。attrset の列挙順は安定しないため、
#     そのまま出力すると switch ごとに並びが変わる
#   - 名前列は Nix 側で桁揃えする (名前は ASCII だけなので
#     stringLength = 表示幅)。アイコンは 1 絵文字 = 2 桁幅を前提にして、
#     全行のアイコンを同じ桁数に揃える
#   - 色は home-manager の lib/bash/home-manager.sh が定義する
#     noteColor / normalColor を使う。setupColors が NO_COLOR と
#     非 tty を見て空にするので、既存メッセージと同じ挙動になる
#   - 表示は linkGeneration の後。ファイルがリンク済みでこそ
#     「適用された」と言えるため
{
  config,
  lib,
  ...
}:

let
  entries = (
    lib.sort (a: b: a.name < b.name) (
      lib.mapAttrsToList (name: value: { inherit name; } // value) config.dotfiles.programs
    )
  );

  nameWidth = lib.foldl' (acc: e: lib.max acc (lib.stringLength e.name)) 0 entries;

  # 右埋めする。lib.strings.fixedWidthString は左埋め + filler 必須なので使わない
  padRight = n: s: s + lib.concatStrings (lib.replicate (n - lib.stringLength s) " ");

  lines = map (
    e: "  ${e.icon} ${padRight nameWidth e.name}${if e.note == "" then "" else "  ${e.note}"}"
  ) entries;
in
{
  options.dotfiles.programs = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          icon = lib.mkOption {
            type = lib.types.str;
            default = "•";
            example = "🦇";
            description = ''
              1 絵文字 (2 桁幅) を推奨。名前列の桁揃えが崩れるので
              ZWJ シーケンスや複数絵文字は使わない
            '';
          };

          note = lib.mkOption {
            type = lib.types.str;
            default = "";
            example = "TwoDark / less pager";
            description = "補足の説明。空なら名前だけ表示する";
          };
        };
      }
    );
    default = { };
    description = ''
      programs/ 配下のモジュールが宣言する「適用済み config」一覧。
      icon と name から activation 時の表示を組み立てる。
    '';
  };

  config.home.activation.appliedPrograms = lib.hm.dag.entryAfter [ "linkGeneration" ] (
    lib.optionalString (entries != [ ]) ''
      printf '%s\n' "''${noteColor}▌ applied program configs (${toString (lib.length entries)})''${normalColor}"
      printf '%s\n' ${lib.escapeShellArgs lines}
    ''
  );
}
