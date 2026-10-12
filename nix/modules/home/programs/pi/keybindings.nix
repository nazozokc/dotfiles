{
  xdg.configFile."pi/agent/keybindings.json".text = builtins.toJSON {
    "$schema" = "https://pi.dev/schemas/keybindings.schema.json";
    "app.session.new" = "ctrl+shift+n";
    "app.session.tree" = "ctrl+shift+t";
    "app.model.select" = "ctrl+l";
    "app.thinking.cycle" = "shift+tab";
  };
}
