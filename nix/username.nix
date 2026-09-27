# ユーザー名の単一ソース
#
# `flake.nix` の `username` はこのファイルを import する。
# homeConfigurations / darwinConfigurations / systemConfigs の
# attr 名と home-manager 設定の両方に使われる。
#
# 値の更新:
# apps.default (bootstrap) が `id -un` と比較し、違う場合だけ
# このファイルを書き換える。値の一致時は touch しない。
# bootstrap を使わない運用なら手で編集する。
#
# なぜ outputs 内で環境変数から取れないのか:
# flake の outputs は pure 評価されるため、実行環境に依存する
# 手段 (whoami / builtins.getEnv / builtins.currentUser) は使えない。
#   - builtins.getEnv "USER" は "" を返すだけ (エラーにならない)
#   - builtins.currentUser は Nix 2.35 に存在しない
# impure 評価は home-manager 起動や `nix flake check` に伝播させられず、
# CI 品質ゲートと `nix run .#switch` が壊れるため採らない。
# 書き込みは bootstrap 側で行い、その後は pure 評価でも同値が見える。
"nazozokc"
