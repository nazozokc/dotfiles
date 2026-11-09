# nix/overlays/rust-packages.nix
# ---------------------------------------------------------------------------
# presenterm: oniguruma の pkg-config 検出漏れを補う
# ---------------------------------------------------------------------------
# nixpkgs の cargo-setup-hook.sh は RUSTONIG_SYSTEM_LIBONIG=1 を常に設定する。
# onig_sys はこれを見て pkg-config 経由で oniguruma を探すが、presenterm の
# パッケージ定義は pkg-config / oniguruma を依存に入れていないため
#   Unable to find oniguruma in pkg-config, and RUSTONIG_SYSTEM_LIBONIG is set
# でビルドが落ちる。
#
# 復活条件: nixpkgs 側で presenterm に pkg-config / oniguruma が追加されたら削除する。
final: prev: {
  presenterm = prev.presenterm.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ prev.pkg-config ];
    buildInputs = (old.buildInputs or [ ]) ++ [ prev.oniguruma ];
  });
}
