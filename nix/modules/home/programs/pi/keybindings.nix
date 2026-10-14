{
  xdg.configFile."pi/agent/keybindings.json".text = builtins.toJSON {
    "$schema" = "https://pi.dev/schemas/keybindings.schema.json";
    "app.session.new" = "ctrl+shift+n";
    "app.session.tree" = "ctrl+shift+t";
    "app.model.select" = "ctrl+l";
    # Shift+Tab: cycle thinking level
    "app.thinking.cycle" = "shift+tab";
    # Tab is used by the agent-modes extension (cycle agent mode), so the
    # built-in Tab / autocomplete action is disabled to stop it claiming the key.
    "tui.input.tab" = [ ];
    "tui.editor.cursorWordLeft" = [ "alt+b" ];
    "tui.editor.cursorWordRight" = [ "alt+f" ];
    "tui.editor.deleteWordBackward" = [ "ctrl+w" ];
    "tui.editor.deleteWordForward" = [ "alt+d" ];
    "tui.history.prev" = [ "ctrl+p" ];
    "tui.history.next" = [ "ctrl+n" ];
    "tui.input.accept" = [ "ctrl+y" ];
    "tui.search.toggle" = [ "ctrl+r" ];
  };
}
