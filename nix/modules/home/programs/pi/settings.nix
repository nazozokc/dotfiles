{ config, pkgs, ... }:

let
  mcpConfig = import ../../../../overlays/mcp/mcp.nix { inherit config pkgs; };
in
{
  xdg.configFile."pi/agent/settings.json".text = builtins.toJSON {
    "$schema" = "https://pi.dev/schemas/settings.schema.json";
    # Exact versions only — agents-doctor rejects unpinned npm packages.
    packages = [
      "npm:opencode-pi@1.5.0"
      "npm:pi-vim@0.16.0"
      "npm:pi-web-access@0.48.0"
    ];
    extensions = [
      "./extensions/codex-usage.ts"
      "./extensions/editor.ts"
      "./extensions/nazozokc-pi"
      "./extensions/agent-modes"
      "./extensions/parallel-agents"
      "./extensions/git"
    ];
    defaultThinkingLevel = "high";
    theme = "system";
    quietStartup = "header";
    tuiMode = "regular";
    fullscreenScrollbar = "auto";
    editorPaddingX = 1;
    autocompleteMaxVisible = 8;
    showHardwareCursor = false;
    doubleEscapeAction = "tree";
  };

  xdg.configFile."pi/agent/mcp.json".text = builtins.toJSON {
    mcpServers = mcpConfig.pi;
  };
}
