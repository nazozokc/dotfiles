# nix/overlays/ai.nix

final: prev:

let
  system = prev.stdenv.hostPlatform.system;
in
{
  inherit (prev._llm-agents.packages.${system})
    amp
    opencode
    coderabbit-cli;
    ollama
};
