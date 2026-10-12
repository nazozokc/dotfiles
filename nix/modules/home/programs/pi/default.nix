{ config, ... }:

{
  dotfiles.programs.pi = {
    icon = "🥧";
    note = "settings / keybindings";
  };

  xdg.configFile = {
    "pi/agent/settings.json".text = builtins.toJSON {
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

    "pi/agent/keybindings.json".text = builtins.toJSON {
      "$schema" = "https://pi.dev/schemas/keybindings.schema.json";
      "app.session.new" = "ctrl+shift+n";
      "app.session.tree" = "ctrl+shift+t";
      "app.model.select" = "ctrl+l";
      "app.thinking.cycle" = "shift+tab";
    };
  };

  home.file.".config/pi/agent/extensions".source = ./extensions;

  home.sessionVariables = {
    PI_CODING_AGENT_DIR = "${config.xdg.configHome}/pi/agent";
  };
}
