final: prev: {
  # AI tools
  # llm-agents.nix は x86_64-darwin (Intel Mac) 向けパッケージを提供しないため、
  # その場合は nixpkgs のパッケージにフォールバックする
  inherit (prev._llm-agents.packages.${prev.stdenv.hostPlatform.system} or prev)
    opencode
    ;

  # coderabbit-cli は nixpkgs に無いシステム (x86_64-darwin) では提供しない
  coderabbit-cli =
    prev._llm-agents.packages.${prev.stdenv.hostPlatform.system}.coderabbit-cli or null;

  # aider-chat-full with bedrock (boto3) needs rsa at runtime
  #
  # nixpkgs の litellm は aider 0.86.1 が想定するより新しく、例外クラスを
  # export するたびに増える。aider の `LiteLLMExceptions._load()` は
  # EXCEPTIONS に無い例外名を見つけると `strict` 引数に関わらず無条件に
  # raise するため、ビルドの pytest だけでなく**実行時も**
  # `LiteLLMExceptions()` の生成 (models.py / base_coder.py) で落ちる。
  # テストを無効化しても実害は消えない。
  #
  # nixpkgs も `ErrorEventError` を allowlist に足す patch で回避しているが
  # 名前が増えるたびに追随が必要になる。未知の例外は `get_ex_info()` が
  # `ExInfo(None, None, None)` へフォールバックするので、チェック自体を外す。
  aider-chat-full =
    let
      # PostHog 7.71 のテストは MCP 2 非対応。Aider の依存スコープだけ MCP 1 を使う。
      python3Packages = final.python3Packages.overrideScope (
        pyFinal: pyPrev: {
          posthog = pyPrev.posthog.override { mcp = pyFinal.mcp_1; };
        }
      );
      aider = (prev.aider-chat.override { inherit python3Packages; }).withOptional {
        withAll = true;
      };
    in
    aider.overridePythonAttrs (old: {
      dependencies = old.dependencies ++ [ python3Packages.rsa ];
      patches = old.patches ++ [ ../patches/aider-chat/ignore-unknown-litellm-exceptions.patch ];
    });
}
