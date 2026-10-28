# nix/overlays/python-mcp2.nix
# ---------------------------------------------------------------------------
# nixpkgs mcp 2.x 対応波の broken 解除
# ---------------------------------------------------------------------------
# nixpkgs unstable の mcp 2.2.0 は McpError を MCPError にリネームした。
# mcp 1.x 前提の fastmcp 3.x 系は import時に ImportError で落ちるため、
# nixpkgs は meta.broken = lib.versionAtLeast mcp.version "2" を付けて
# 評価を拒否している (posthog / fastmcp-slim / fastapi-mcp /
# django-mcp-server / gradio の 5 件が該当)。
#
# 本 dotfiles での関係:
# - oterm: fastmcp を直接使うため ImportError で実行不能。
#   nix/modules/home/programs/ollama/default.nix で無効化済み。
# - posthog (aider-chat-full の依存): aider は匿名アナリティクスの
#   POST 送信だけに使う。ビルド結果は 4199 passed / 1 failed で、
#   失敗は posthog 自身の MCP 機能の test 1 件のみ
#   (test_prepare_tool_result_delivers_into_call_tool_result_models)。
#   broken 解除 + その test のみ除外で aider は mcp 2.x でも問題なく動く。
#
# fastmcp 4.x 化の PR https://github.com/NixOS/nixpkgs/pull/563493 が
# マージされて mcp 2.x 対応の fastmcp 4.x が入ったら削除してよい。
_final: prev: {
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (_pyfinal: pyprev: {
      posthog = pyprev.posthog.overridePythonAttrs (old: {
        meta = old.meta // {
          broken = false;
        };
        disabledTests = (old.disabledTests or [ ]) ++ [
          "test_prepare_tool_result_delivers_into_call_tool_result_models"
        ];
      });
    })
  ];
}
