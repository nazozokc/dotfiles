final: prev: {
  # AI tools
  inherit (prev._llm-agents.packages.${prev.stdenv.hostPlatform.system})
    opencode
    coderabbit-cli
    ;

  # aider-chat-full with bedrock (boto3) needs rsa at runtime
  aider-chat-full = prev.aider-chat-full.overridePythonAttrs (old: {
    dependencies = old.dependencies ++ [ final.python3Packages.rsa ];
  });
}
