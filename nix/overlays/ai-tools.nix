_final: prev: {
  # AI tools
  # llm-agents.nix は x86_64-darwin (Intel Mac) 向けパッケージを提供しないため、
  # その場合は nixpkgs のパッケージにフォールバックする
  inherit (prev._llm-agents.packages.${prev.stdenv.hostPlatform.system} or prev)
    opencode
    ;

  # coderabbit-cli は nixpkgs に無いシステム (x86_64-darwin) では提供しない
  coderabbit-cli =
    prev._llm-agents.packages.${prev.stdenv.hostPlatform.system}.coderabbit-cli or null;

  # OpenHands Agent Canvas も llm-agents.nix 由来。
  # x86_64-darwin は上流が packages を出していないため null にする (利用側で除外)。
  openhands-agent-canvas =
    prev._llm-agents.packages.${prev.stdenv.hostPlatform.system}.openhands-agent-canvas or null;
}
