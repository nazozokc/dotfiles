_final: prev: {
  # AI tools
  inherit (prev._llm-agents.packages.${prev.stdenv.hostPlatform.system})
    opencode
    coderabbit-cli
    ;
}
