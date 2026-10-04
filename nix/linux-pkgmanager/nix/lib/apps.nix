# nix/lib/apps.nix
# 組み立て済みの nlp から flake の apps を作る。
#
# このリポジトリ自身 (nix/flake-module.nix) も、
# flake-parts を使わない消費側 (nix/lib/mk-apps.nix) もここを通す。
# ラッパーの形が 2 箇所に分かれると、片側だけ引数の渡し方を壊す。
#
# `program` は空白を含むと実行できない。
# nix run は program 文字列を argv[0] として直接 execve するため、
# ".../bin/nlp diff" は ENOENT になる。
# app ごとに引数無しのラッパーを置き、そこから nlp へ委譲する。
{
  lib,
  pkgs,
  nlp,
  appPrefix ? "",
  defaultApp ? null,
}:
let
  commands = {
    diff = "宣言と導入済みを比較する (副作用なし)";
    adopt = "明示導入済みを宣言の雛形として出す (副作用なし)";
    apply = "不足しているパッケージを導入する";
    update = "パッケージマネージャーを更新してから不足分を補う";
    status = "検出したパッケージマネージャーと宣言の件数";
  };

  mkApp =
    subcommand: description:
    let
      wrapper = pkgs.writeShellApplication {
        name = "nlp-${subcommand}";
        runtimeInputs = [ nlp ];
        # 第1引数にコマンド名を固定しつつ、後ろのフラグはそのまま渡す
        # (`nix run .#apply -- --help` を効かせるため)
        text = "exec ${nlp}/bin/nlp ${subcommand} \"$@\"";
      };
    in
    {
      type = "app";
      meta.description = description;
      program = "${wrapper}/bin/nlp-${subcommand}";
    };

  named = lib.mapAttrs mkApp commands;

  apps = lib.mapAttrs' (name: app: lib.nameValuePair "${appPrefix}${name}" app) named;
in
{
  package = nlp;
  apps =
    apps
    // lib.optionalAttrs (defaultApp != null) {
      default = apps."${appPrefix}${defaultApp}";
    };
}
