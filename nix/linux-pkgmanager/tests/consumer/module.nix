# tests/consumer/module.nix
# 消費側の最小構成。flake-parts の imports にそのまま渡せる形にしてある。
#
#   imports = [ inputs.linux-pkgmanager.nix.flakeModules.default ];  # ← nlpModule
#
# checks.consumer (nix/flake-parts/checks.nix) はこのモジュールを
# 入力を移した消費側 flake として評価し、公開 API の形と宣言の
# 焼き込みを固定する。
#
# 宣言は「パス」と「インライン」を混ぜて書く。
# 公開 API が壊れても「消費側のコードは書き方のまま」なので、
# いちばん素直なものをそのままフィクスチャにする
{
  nlpModule ? ../../nix/flake-module.nix,
  ...
}:
{
  imports = [ nlpModule ];

  nlp = {
    declared = {
      # ファイル指定。このリポジトリ自身の宣言ファイルを消費側の形で使う
      pacman = ../../packages/pacman.nix;
      dnf = ../../packages/dnf.nix;
      zypper = ../../packages/zypper.nix;
      yum = ../../packages/yum.nix;

      # インライン
      apt = [
        "man-db"
        "bash-completion"
        "bat"
      ];
    };

    # 接頭辞は既定 (nlp-) のまま。apps.default を通す経路も見る
    defaultApp = "diff";
  };
}
