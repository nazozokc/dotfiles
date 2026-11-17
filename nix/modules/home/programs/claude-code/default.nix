{
  config,
  pkgs,
  lib,
  dotfilesDir,
  ...
}:

let
  homeDir = config.home.homeDirectory;
  claudeConfigDir = "${homeDir}/.config/claude";
  link = config.lib.file.mkOutOfStoreSymlink;
  mcpConfig = import ../../../../overlays/mcp/mcp.nix { inherit config pkgs; };
  mcpServersJson = builtins.toJSON mcpConfig.claudeCode;

  settings = {
    permissions = {
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
  };
in
{
  dotfiles.programs.claude-code = {
    icon = "🤖";
    note = "settings.json + CLAUDE.md";
  };

  home.activation = {
    claudeCodeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "${claudeConfigDir}"
      ${pkgs.jq}/bin/jq -n '${builtins.toJSON settings}' > "${claudeConfigDir}/settings.json"
      chmod 644 "${claudeConfigDir}/settings.json"
    '';

    # user-scope MCP servers は settings.json ではなく ~/.claude.json の mcpServers。
    # Claude Code 自身が書き込む他のキーを壊さないよう jq でマージする。
    claudeCodeMcp = lib.hm.dag.entryAfter [ "claudeCodeSettings" ] ''
      claude_json="${homeDir}/.claude.json"
      tmp="$(mktemp "${homeDir}/.claude.json.XXXXXX")"
      if [ -f "$claude_json" ]; then
        ${pkgs.jq}/bin/jq --argjson mcp '${mcpServersJson}' \
          '.mcpServers = ((.mcpServers // {}) + $mcp)' "$claude_json" > "$tmp"
      else
        ${pkgs.jq}/bin/jq -n --argjson mcp '${mcpServersJson}' '{mcpServers: $mcp}' > "$tmp"
      fi
      mv "$tmp" "$claude_json"
      chmod 600 "$claude_json"
    '';
  };

  # グローバル指示: agent-memoryの保存ルールを毎セッション読み込ませる
  home.file.".claude/CLAUDE.md" = {
    source = link "${dotfilesDir}/claude/CLAUDE.md";
  };
}
