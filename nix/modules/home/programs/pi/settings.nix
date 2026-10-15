{
  xdg.configFile."pi/agent/settings.json".text = builtins.toJSON {
    "$schema" = "https://pi.dev/schemas/settings.schema.json";
    packages = [
      "npm:opencode-pi"
      "npm:pi-vim"
      "npm:pi-web-access"
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
}
