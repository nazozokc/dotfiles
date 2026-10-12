{
  xdg.configFile."pi/agent/settings.json".text = builtins.toJSON {
    "$schema" = "https://pi.dev/schemas/settings.schema.json";
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
