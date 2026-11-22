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
    # Prompt history. The old tui.history.* names were never recognised by pi,
    # so free the two defaults that would otherwise claim the same keys.
    "app.model.cycleForward" = [ ];
    "app.session.toggleNamedFilter" = [ ];
    "tui.editor.historyPrevious" = [ "ctrl+p" ];
    "tui.editor.historyNext" = [ "ctrl+n" ];
    # Transcript search (the old tui.search.toggle was ignored).
    "tui.altScreen.search" = [ "ctrl+r" ];
  };
}
