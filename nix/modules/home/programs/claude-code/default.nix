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
  permConfig = import ../../../../overlays/mcp/permissions.nix { };
  roles = import ../../../../lib/agent-roles.nix;

  # Claude Code subagents are Markdown files with YAML frontmatter.
  # Tools are an explicit allowlist so a read-only role stays read-only.
  claudeTools = {
    build = "Bash, Read, Edit, Write, Glob, Grep";
    plan = "Read, Glob, Grep";
    explore = "Read, Glob, Grep";
    scout = "Read, Glob, Grep";
    review = "Bash, Read, Glob, Grep";
    test = "Bash, Read, Glob, Grep";
  };
  claudeAgent = name: ''
    ---
    name: ${name}
    description: ${roles.${name}.description}
    tools: ${claudeTools.${name}}
    model: inherit
    ---
    ${roles.${name}.prompt}
  '';
  claudeAgents = lib.listToAttrs (
    map (name: {
      name = ".claude/agents/${name}.md";
      value.text = claudeAgent name;
    }) roles.roles
  );

  settings = {
    permissions = permConfig.claudeCode;
  };
in
{
  dotfiles.programs.claude-code = {
    icon = "🤖";
    note = "settings.json + CLAUDE.md + 6 agents";
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
  home.file = claudeAgents // {
    ".claude/CLAUDE.md" = {
      source = link "${dotfilesDir}/claude/CLAUDE.md";
    };
  };
}
