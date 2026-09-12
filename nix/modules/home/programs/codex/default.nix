# nix/modules/home/programs/codex/default.nix
# OpenAI Codex CLI: グローバル指示 (AGENTS.md) をデプロイする
{
  config,
  dotfilesDir,
  ...
}:
{
  # グローバル指示: agent-memoryの保存ルールを毎セッション読み込ませる
  home.file.".codex/AGENTS.md" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/codex/AGENTS.md";
  };
}
