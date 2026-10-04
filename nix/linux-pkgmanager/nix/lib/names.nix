# nix/lib/names.nix
# pm が受理するパッケージ名の「形」を 1 箇所に閉じる。
#
# 使う場所は 2 つで、片方だけを検査すると漏れる:
#
#   宣言の検査 (nix/lib/declared.nix)  評価時。宣言に悪い名前があれば落とす
#   adopt の生成 (nix/lib/render.nix)  実行時。pm が出した名前を宣言へ書き出す
#
# adopt を足す前は検査側しか無かった。生成側が同じ規則がないと、
# `nlp adopt > packages/pacman.nix` が「評価時に落ちる宣言」を作る。
# それは nlp が最初に落とした値そのものなので、両方を同じ 1 つの定義に寄せる
#
# backends.nix ではなく独立させているのは、名前が 1 pm ではなく
# 「5 pm 全体に効く規則」だから。backends.nix は pms = attrNames backends で
# 回されるため、ここに置くと「pm ではない属性」が pm として混入する
{
  # 素の英数字と . + - _ : だけを許す。空白 / $ ; ` / glob 文字はすべて弾く。
  #
  #   通る名前: gcc-c++ python3.11 lib32-gtk3 nvidia-550xx-dkms java-17-openjdk
  #   弾く名前: "ripgrep; rm -rf /" "a b" "$(id)" "*" "-rf"
  #
  # 行頭も英数字に限定している。`-rf` や `*` を弾くのは形の問題ではなく、
  # pm 側のオプションと glob として読まれる危険があるため
  pattern = "^[A-Za-z0-9][A-Za-z0-9+._:-]*$";

  # エラーメッセージに出す「使える文字」の説明。
  # declared.nix (評価時) と 60-commands.sh の adopt (実行時) が同じ文言を使う
  hint = "英数字と . + - _ :";
}
