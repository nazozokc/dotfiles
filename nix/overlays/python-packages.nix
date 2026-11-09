# nix/overlays/python-packages.nix
# ---------------------------------------------------------------------------
# posthog: mcp 2.x でテストが壊れるため nixpkgs が broken 扱いしている
# ---------------------------------------------------------------------------
# nixpkgs の posthog は
#   meta.broken = lib.versionAtLeast mcp.version "2";
# となっており、nixpkgs unstable の mcp 2.3.0 では評価自体が拒否される。
#
# しかし mcp は nativeCheckInputs (テスト専用) の依存で、実行時依存は
# backoff / distro / requests / typing-extensions のみ。
# aider-chat が posthog を実行時依存として使っているため、テストだけ無効化して
# パッケージを利用可能にする。
#
# 復活条件: nixpkgs 側で posthog が mcp 2.x 対応したらこの overlay を削除する。
final: prev: {
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (pyFinal: pyPrev: {
      posthog = pyPrev.posthog.overridePythonAttrs (old: {
        # テストは mcp 2.x の API 変更で落ちる (実行時依存ではない)
        doCheck = false;
        meta = old.meta // {
          broken = false;
        };
      });

      # streamlit 1.62.0 は pillow<13 を要求するが、nixpkgs の pillow は 13.0.0。
      # pythonRuntimeDepsCheckHook で落ちるため pillow の制約を緩める。
      streamlit = pyPrev.streamlit.overridePythonAttrs (old: {
        pythonRelaxDeps = (old.pythonRelaxDeps or [ ]) ++ [ "pillow" ];
      });
    })
  ];
}
