# nix/lib/ai-config.nix
# AI エージェントの既定値。切り替え・追加はここ1箇所で行う。
{
  # T3 Code の既定プロバイダ。切り替えるなら "codex" に変えるだけ。
  t3codeProvider = "opencode";

  # T3 Code のモデル ID (<provider>/<model> 形式)
  t3codeModels = {
    opencode = "opencode/big-pickle";
    codex = "codex/gpt-5";
  };

  # Ollama 起動時に存在確認し、無いものだけ pull するモデル。
  ollamaModels = [
    "qwen2.5:0.5b"
    "qwen2.5-coder:1.5b"
    "nomic-embed-text"
  ];
}
