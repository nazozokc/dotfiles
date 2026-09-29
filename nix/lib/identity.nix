# nix/lib/identity.nix
# 「誰の dotfiles なのか」を決める値。attr 名・パス生成の唯一の入口。
#
# flake の pure 評価では環境変数も whoami も参照できない (Nix 2.35 で実測)。
#   builtins.getEnv "USER" は "" を返すだけ / builtins.currentUser は存在しない
# 実行環境のユーザー名は bootstrap (nix/parts/apps/bootstrap.nix) が `id -un` から
# 取り、この 2 つの値を apps へ渡すことで pure 評価の中に持ち込む。
{
  # ローカルユーザー名。
  # homeConfigurations / darwinConfigurations / systemConfigs の attr 名と
  # nix/shared.nix の home.username / home.homeDirectory になる。
  username = "nazozokc";

  # この dotfiles リポジトリの GitHub 所有者。
  # bootstrap の clone 先 (ghq レイアウト: github.com/<owner>/dotfiles) に使う。
  # ローカルユーザー名 (username) とは別物なので、別ユーザーで運用していても
  # clone 先は変わらない。fork 時だけ変更する。
  repoOwner = "nazozokc";
}
