{
  xdg.configFile."pi/agent/keybindings.json".text = builtins.toJSON {
    "$schema" = "https://pi.dev/schemas/keybindings.schema.json";
    "app.session.new" = "ctrl+shift+n";
    "app.session.tree" = "ctrl+shift+t";
    "app.model.select" = "ctrl+l";
    "app.thinking.cycle" = "shift+tab";
    "tui.editor.cursorWordLeft" = [ "alt+b" ];
    "tui.editor.cursorWordRight" = [ "alt+f" ];
    "tui.editor.deleteWordBackward" = [ "ctrl+w" ];
    "tui.editor.deleteWordForward" = [ "alt+d" ];
    "tui.input.accept" = [ "ctrl+y" ];
    "tui.history.prev" = [ "ctrl+p" ];
    "tui.history.next" = [ "ctrl+n" ];
    "tui.search.toggle" = [ "ctrl+r" ];
    "tui.tabs.next" = [ "ctrl+tab" ];
    "tui.tabs.prev" = [ "ctrl+shift+tab" ];
  };
}
