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
  # litellm 1.102.1 が `VectorStoreSearchError` を export し始めたが、aider
  # 0.86.1 の `aider/exceptions.py` の EXCEPTIONS に無い。
  # `_load()` は `strict` 引数に関わらず無条件に raise するため、ビルドの
  # pytest だけでなく**実行時も** `LiteLLMExceptions()` の生成
  # (models.py / base_coder.py) で落ちる。テストを無効化しても実害は消えない。
  #
  # nixpkgs が持つ 2 つの例外追加 patch の後に、1 件だけ足す。
  # upstream fix: https://github.com/Aider-AI/aider/pull/5782
  aider-chat-full = prev.aider-chat-full.overridePythonAttrs (old: {
    dependencies = old.dependencies ++ [ final.python3Packages.rsa ];
    patches = old.patches ++ [ ../patches/aider-chat/add-vector-store-search-error.patch ];
  });
}
