-- Purpose: keyboard-only window/pane/tab control. No tmux-style prefix, no Ctrl-alone binds.

local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

function M.apply(config)
  -- Defaults include Ctrl-only bindings (zoom, etc). We disable them to enforce the rule strictly.
  config.disable_default_key_bindings = true

  config.keys = {
    -- Tabs
    { key = "t",        mods = "CTRL|SHIFT",     action = act.SpawnTab("CurrentPaneDomain") },
    { key = "w",        mods = "CTRL|SHIFT",     action = act.CloseCurrentTab({ confirm = true }) },
    -- PageUp/Down avoids hijacking hjkl, which we keep for pane focus.
    { key = "PageUp",   mods = "CTRL|SHIFT",     action = act.ActivateTabRelative(-1) },
    { key = "PageDown", mods = "CTRL|SHIFT",     action = act.ActivateTabRelative(1) },

    -- Panes: split
    { key = "e",        mods = "CTRL|SHIFT",     action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { key = "d",        mods = "CTRL|SHIFT",     action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
    { key = "q",        mods = "CTRL|SHIFT",     action = act.CloseCurrentPane({ confirm = true }) },
    { key = "z",        mods = "CTRL|SHIFT",     action = act.TogglePaneZoomState },

    -- Panes: focus (Vim-like mnemonics, but only as a terminal UI concern)
    { key = "h",        mods = "CTRL|SHIFT",     action = act.ActivatePaneDirection("Left") },
    { key = "j",        mods = "CTRL|SHIFT",     action = act.ActivatePaneDirection("Down") },
    { key = "k",        mods = "CTRL|SHIFT",     action = act.ActivatePaneDirection("Up") },
    { key = "l",        mods = "CTRL|SHIFT",     action = act.ActivatePaneDirection("Right") },

    -- Panes: resize (extra Alt to avoid accidental resizing while navigating)
    { key = "h",        mods = "CTRL|SHIFT|ALT", action = act.AdjustPaneSize({ "Left", 3 }) },
    { key = "j",        mods = "CTRL|SHIFT|ALT", action = act.AdjustPaneSize({ "Down", 2 }) },
    { key = "k",        mods = "CTRL|SHIFT|ALT", action = act.AdjustPaneSize({ "Up", 2 }) },
    { key = "l",        mods = "CTRL|SHIFT|ALT", action = act.AdjustPaneSize({ "Right", 3 }) },

    -- Window
    { key = "Enter",    mods = "CTRL|SHIFT",     action = act.ToggleFullScreen },
    { key = "n",        mods = "CTRL|SHIFT",     action = act.SpawnWindow },

    -- Clipboard (terminal-layer; does not interfere with Neovim normal-mode bindings)
    { key = "c",        mods = "CTRL|SHIFT",     action = act.CopyTo("Clipboard") },
    { key = "v",        mods = "CTRL|SHIFT",     action = act.PasteFrom("Clipboard") },

    -- Config management
    { key = "r",        mods = "CTRL|SHIFT",     action = act.ReloadConfiguration },
    -- Useful when you need WezTerm-only actions; avoids introducing extra bespoke keybinds.
    { key = "p",        mods = "CTRL|SHIFT",     action = act.ActivateCommandPalette },
    -- ============================
    -- Alt + Enter : Fullscreen toggle
    -- ============================
    {
      key = "Enter",
      mods = "ALT",
      action = act.ToggleFullScreen,
    },

    -- ============================
    -- Ctrl + Shift + F : Opacity toggle
    -- ============================
    {
      key = "F",
      mods = "CTRL|SHIFT",
      action = wezterm.action_callback(function(window, _)
        local overrides = window:get_config_overrides() or {}

        -- トグル判定：
        -- nil or 1.0 → 透過ON
        -- それ以外     → 不透明
        if overrides.window_background_opacity
            or overrides.window_background_opacity == 0.90
        then
          overrides.window_background_opacity = 0.75
        else
          overrides.window_background_opacity = 0.90
        end

        window:set_config_overrides(overrides)
      end),
    },
  }
end

return M
