# MCP サーバー定義の single source of truth。
# 各エージェントは to* で自前の形式へ変換して使う。
{ config, pkgs, ... }:

let
  inherit (pkgs) lib;
  inherit (config.home) homeDirectory;

  servers = {
    context7 = {
      type = "local";
      # bunx -y は起動のたびにレジストリへ触れるので Nix store の実体を使う
      command = [ "${pkgs.context7-mcp}/bin/context7-mcp" ];
    };

    TypescriptDocs = {
      type = "remote";
      url = "https://gitmcp.io/microsoft/TypeScript";
    };

    github = {
      type = "local";
      # トークンは fish/conf.d/ai-secrets.fish が
      # GITHUB_PERSONAL_ACCESS_TOKEN として export する
      command = [
        "${pkgs.github-mcp-server}/bin/github-mcp-server"
        "stdio"
      ];
    };

    git = {
      type = "local";
      command = [ "${pkgs.mcp-server-git}/bin/mcp-server-git" ];
    };

    samemory = {
      type = "local";
      command = [
        "bunx"
        "samemory@latest"
      ];
    };

    nixos = {
      type = "local";
      command = [ "${pkgs.mcp-nixos}/bin/mcp-nixos" ];
    };
  }
  // lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
    playwright = {
      type = "local";
      command = [
        "${pkgs.playwright-mcp}/bin/playwright-mcp"
        "--browser"
        "chromium"
        "--no-sandbox"
      ];
      environment = {
        PWMCP_PROFILES_DIR_FOR_TEST = "${homeDirectory}/.local/share/playwright-mcp/profiles";
      };
    };
  };

  toOpencode =
    server:
    {
      inherit (server) type;
      enabled = true;
    }
    // (
      if server.type == "local" then
        {
          inherit (server) command;
        }
        // (if (server.environment or { }) == { } then { } else { inherit (server) environment; })
      else
        { inherit (server) url; }
    );

  toClaudeCode =
    server:
    (
      if server.type == "local" then
        {
          type = "stdio";
          command = builtins.head server.command;
          args = builtins.tail server.command;
        }
        // (if (server.environment or { }) == { } then { } else { env = server.environment; })
      else
        {
          type = "http";
          inherit (server) url;
        }
    );

  # Codex は command / url の有無で transport を決めるので type キーは不要。
  toCodex = server: builtins.removeAttrs (toClaudeCode server) [ "type" ];

  # Pi 1.x は stdio / http をエイリアスとして受け付ける。起動時に接続させる。
  toPi = server: toClaudeCode server // { lifecycle = "eager"; };
in
{
  inherit servers;

  opencode = lib.mapAttrs (_: toOpencode) servers;
  claudeCode = lib.mapAttrs (_: toClaudeCode) servers;
  codex = lib.mapAttrs (_: toCodex) servers;
  pi = lib.mapAttrs (_: toPi) servers;
}
