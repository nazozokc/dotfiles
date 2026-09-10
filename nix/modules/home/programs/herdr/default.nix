{ ... }:

{
  xdg.configFile."herdr/config.toml".text = ''
    # Herdr configuration.
    #
    # Keybinding design:
    #   - Direct chords (ctrl/ctrl+shift/...) mirror the WezTerm keymap so
    #     pane/tab navigation feels identical in both tools.
    #   - Prefix-mode bindings (prefix+x) cover Herdr-specific actions:
    #     workspace management, pane swap/cycle, popups, and helpers.
    onboarding = false

    [theme]
    # Kanagawa is the same base palette WezTerm uses (kanagawa.nvim).
    name = "kanagawa"

    # Match WezTerm's appearance.lua colors exactly.
    [theme.custom]
    accent = "#C8C093"
    panel_bg = "#181616"
    sidebar_bg = "#181616"
    selection_bg = "#2D4F67"
    text = "#c5c9c5"
    green = "#8A9A7B"
    yellow = "#C4B28A"
    red = "#C4746E"
    blue = "#8BA4B0"
    teal = "#8EA4A2"
    peach = "#B6927B"
    mauve = "#A292A3"

    [terminal]
    # Inherit the source pane/workspace directory for new panes.
    new_cwd = "follow"

    [keys]
    prefix = "ctrl+b"

    # --- Tabs -----------------------------------------------------------
    # ctrl+t / ctrl+w are plain-Ctrl chords so they pass through the outer
    # terminal (WezTerm keeps ctrl+shift+t/w). The rest mirror WezTerm.
    new_tab = "ctrl+t"
    close_tab = "ctrl+w"
    previous_tab = "ctrl+shift+["
    next_tab = "ctrl+shift+]"
    switch_tab = "ctrl+shift+1..9"
    move_tab_previous = "alt+shift+left"
    move_tab_next = "alt+shift+right"

    # --- Panes ----------------------------------------------------------
    # split names follow WezTerm: d = vertical (side-by-side), e = horizontal.
    split_vertical = "ctrl+shift+d"
    split_horizontal = "ctrl+shift+e"
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
    last_pane = "prefix+`"

    # --- Workspaces -----------------------------------------------------
    previous_workspace = "ctrl+shift+alt+["
    next_workspace = "ctrl+shift+alt+]"
    switch_workspace = "prefix+shift+1..9"

    # --- Utility --------------------------------------------------------
    copy_mode = "ctrl+shift+x"
    reload_config = "ctrl+shift+r"

    # --- Popup helpers (prefix+alt+...) ---------------------------------
    [[keys.command]]
    key = "prefix+alt+g"
    type = "popup"
    command = "lazygit"
    description = "run lazygit"
    width = "80%"
    height = "80%"

    [[keys.command]]
    key = "prefix+alt+b"
    type = "popup"
    command = "btop"
    description = "run btop"
    width = "80%"
    height = "80%"

    [[keys.command]]
    key = "prefix+alt+t"
    type = "popup"
    command = "exec \"''${SHELL:-sh}\""
    description = "open scratch terminal"
    width = "80%"
    height = "80%"

    # Legacy indexed shortcuts (kept for direct ctrl+shift+alt+1..9
    # workspace switching).
    [keys.indexed]
    workspaces = "ctrl+shift+alt"

    [ui]
    # Hide the tab row when a workspace has exactly one tab
    # (WezTerm's hide_tab_bar_if_only_one_tab).
    hide_tab_bar_when_single_tab = true

    # Ordered right-aligned tab bar status: zoom pill, hostname, time.
    tab_bar_right = [
      { type = "zoom" },
      { type = "hostname" },
      { type = "datetime", format = "%H:%M" },
    ]
    tab_bar_right_separator = " · "

    # Outer terminal title, mirrors the WezTerm status bar workspace label.
    window_title = "{hostname}: {workspace}"

    # Mouse drag / double-click selection copies automatically.
    copy_on_select = true
  '';
}
