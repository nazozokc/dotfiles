# nix/lib/agent-roles.nix
# subagent / agent mode の共通定義。
#
# ここを prompt と description の single source とし、以下へ接続する:
#   - opencode : nix/modules/home/programs/opencode/default.nix
#   - claude   : nix/modules/home/programs/claude-code/default.nix (agents/*.md を生成)
#   - codex    : nix/modules/home/programs/codex/default.nix (agents/*.toml を生成)
#   - pi       : extensions/parallel-agents/* と extensions/agent-modes/*
#                (TS 側の文面は agents-doctor がこのファイルと突き合わせる)
#
# mode / 権限 / ツール集合は各エージェントの仕様が異なるため、このファイルでは持たない。
{
  # Task ツールから起動できる subagent ロール。
  subagents = [
    "explore"
    "review"
    "scout"
    "test"
  ];

  # 全エージェント共通のロール (primary と subagent を含む)。
  roles = [
    "build"
    "plan"
    "explore"
    "scout"
    "review"
    "test"
  ];

  build = {
    description = "Implement features, fix bugs, write code following existing patterns";
    prompt = "You are a build agent. Focus on implementing features, fixing bugs, and writing code. Follow existing patterns and conventions.";
  };

  plan = {
    description = "Architecture, design, and detailed implementation plans";
    prompt = "You are a planning agent. Focus on architecture, design, and creating detailed implementation plans. Think before acting.";
  };

  explore = {
    description = "Read-only codebase exploration: patterns, structure, context";
    prompt = "You are an exploration agent. Focus on understanding the codebase, finding patterns, and gathering context.";
  };

  scout = {
    description = "Quick read-only information gathering and codebase questions";
    prompt = "You are a scout agent. Focus on quick information gathering and answering questions about the codebase.";
  };

  review = {
    description = "Review current changes for correctness, security, and maintainability";
    prompt = "You are a code review agent. Review the current changes for correctness, security, and maintainability. Report concrete findings with file:line references and severity. Do not modify files.";
  };

  test = {
    description = "Write or update focused tests and run the relevant test commands";
    prompt = "You are a test agent. Write or update focused tests for the current changes, run the relevant test commands, and report failures and coverage gaps.";
  };
}
