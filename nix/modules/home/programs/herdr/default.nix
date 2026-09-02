{ ... }:

{
  xdg.configFile."herdr/config.toml".text = ''
    # Herdr keybindings: mirror the Ctrl+Shift namespace used by WezTerm.
    # Direct chords keep pane and tab navigation consistent inside WezTerm.
    onboarding = false

    [keys]
    prefix = "ctrl+b"

    # Tabs
    new_tab = "ctrl+shift+t"
    close_tab = "ctrl+shift+w"
    previous_tab = "ctrl+shift+["
    next_tab = "ctrl+shift+]"
    switch_tab = "ctrl+shift+1..9"

    # Panes
    split_vertical = "ctrl+shift+f"
    split_horizontal = "ctrl+shift+g"
    close_pane = "ctrl+shift+q"
    zoom = "ctrl+shift+z"
    focus_pane_left = "ctrl+shift+h"
    focus_pane_down = "ctrl+shift+j"
    focus_pane_up = "ctrl+shift+k"
    focus_pane_right = "ctrl+shift+l"
    resize_pane_left = "ctrl+shift+alt+h"
    resize_pane_down = "ctrl+shift+alt+j"
    resize_pane_up = "ctrl+shift+alt+k"
    resize_pane_right = "ctrl+shift+alt+l"

    # Workspaces
    previous_workspace = "ctrl+shift+alt+["
    next_workspace = "ctrl+shift+alt+]"

    # Utility
    copy_mode = "ctrl+shift+x"
    reload_config = "ctrl+shift+r"

    # Numbered workspaces use Ctrl+Shift+Alt+1..9.
    [keys.indexed]
    workspaces = "ctrl+shift+alt"
  '';
}
