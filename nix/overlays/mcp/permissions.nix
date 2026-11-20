# エージェント共通の権限ポリシー。
# MCP (overlays/mcp/mcp.nix) と同じく、ここを single source として
# 各エージェントの形式へ変換して使う。
_:
let
  # opencode のツール名を共通語彙にする
  opencode = {
    read = "allow";
    edit = "allow";
    glob = "allow";
    grep = "allow";
    list = "allow";
    bash = "ask";
    task = "ask";
    webfetch = "allow";
    websearch = "allow";
    skill = "allow";
    todowrite = "allow";
    question = "ask";
    lsp = "allow";
  };

  # Claude Code は Bash のパターン列で権限を表現する
  claudeCode = {
    allow = [
      "Bash(git:*)"
      "Bash(nix:*)"
      "Bash(fish:*)"
      "Bash(nvim:*)"
      "Bash(cat:*)"
      "Bash(ls:*)"
      "Bash(find:*)"
      "Bash(grep:*)"
      "Bash(rg:*)"
      "Bash(fd:*)"
      "Bash(bat:*)"
      "Bash(eza:*)"
      "Bash(mkdir:*)"
      "Bash(cp:*)"
      "Bash(mv:*)"
      "Bash(rm:*)"
      "Bash(touch:*)"
      "Bash(echo:*)"
      "Bash(which:*)"
      "Bash(gh:*)"
      "Bash(node:*)"
      "Bash(vite:*)"
      "Bash(bun:*)"
      "Bash(deno:*)"
    ];
    deny = [
      "Bash(sudo:*)"
      "Bash(curl:*)"
      "Bash(wget:*)"
      "Bash(rm -rf /*:*)"
      "Bash(rm -rf ~/*:*)"
    ];
  };

  # Codex は approval と sandbox を別軸で持つ
  codex = {
    approval_policy = "on-request";
    sandbox_mode = "workspace-write";
    sandbox_workspace_write = {
      network_access = true;
    };
  };
in
{
  inherit opencode claudeCode codex;
}
