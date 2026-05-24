-- Purpose: keyboard-only window/pane/tab control. No tmux-style prefix, no Ctrl-alone binds.
-- All keybindings have description for command palette discoverability.

local wezterm = require("wezterm")
local platform = require("utils.platform")
local act = wezterm.action

local M = {}

-- Calculate a "more transparent" value based on the platform default.
local function transparent_opacity()
	local base = platform.default_window_opacity()
	-- When base is 0.95 → 0.75; when base is 0.90 → 0.75; never go below 0.60.
	return math.max(base - 0.15, 0.60)
end

function M.apply(config)
	-- Defaults include Ctrl-only bindings (zoom, etc). We disable them to enforce the rule strictly.
	config.disable_default_key_bindings = true

	config.keys = {
		-- ========================
		-- Tabs
		-- ========================
		{
			key = "t",
			mods = "CTRL|SHIFT",
			action = act.SpawnTab("CurrentPaneDomain"),
			description = "Open new tab",
		},
		{
			key = "w",
			mods = "CTRL|SHIFT",
			action = act.CloseCurrentTab({ confirm = true }),
			description = "Close current tab",
		},
		-- PageUp/Down avoids hijacking hjkl, which we keep for pane focus.
		{
			key = "PageUp",
			mods = "CTRL|SHIFT",
			action = act.ActivateTabRelative(-1),
			description = "Activate previous tab",
		},
		{
			key = "PageDown",
			mods = "CTRL|SHIFT",
			action = act.ActivateTabRelative(1),
			description = "Activate next tab",
		},

		-- ========================
		-- Panes: split
		-- ========================
		{
			key = "e",
			mods = "CTRL|SHIFT",
			action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
			description = "Split pane horizontally",
		},
		{
			key = "d",
			mods = "CTRL|SHIFT",
			action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
			description = "Split pane vertically",
		},
		{
			key = "q",
			mods = "CTRL|SHIFT",
			action = act.CloseCurrentPane({ confirm = true }),
			description = "Close current pane",
		},
		{
			key = "z",
			mods = "CTRL|SHIFT",
			action = act.TogglePaneZoomState,
			description = "Toggle pane zoom state",
		},

		-- ========================
		-- Panes: focus (Vim-like mnemonics)
		-- ========================
		{
			key = "h",
			mods = "CTRL|SHIFT",
			action = act.ActivatePaneDirection("Left"),
			description = "Focus pane to the left",
		},
		{
			key = "j",
			mods = "CTRL|SHIFT",
			action = act.ActivatePaneDirection("Down"),
			description = "Focus pane below",
		},
		{
			key = "k",
			mods = "CTRL|SHIFT",
			action = act.ActivatePaneDirection("Up"),
			description = "Focus pane above",
		},
		{
			key = "l",
			mods = "CTRL|SHIFT",
			action = act.ActivatePaneDirection("Right"),
			description = "Focus pane to the right",
		},

		-- ========================
		-- Panes: resize (extra Alt to avoid accidental resizing)
		-- ========================
		{
			key = "h",
			mods = "CTRL|SHIFT|ALT",
			action = act.AdjustPaneSize({ "Left", 3 }),
			description = "Resize pane left",
		},
		{
			key = "j",
			mods = "CTRL|SHIFT|ALT",
			action = act.AdjustPaneSize({ "Down", 2 }),
			description = "Resize pane down",
		},
		{
			key = "k",
			mods = "CTRL|SHIFT|ALT",
			action = act.AdjustPaneSize({ "Up", 2 }),
			description = "Resize pane up",
		},
		{
			key = "l",
			mods = "CTRL|SHIFT|ALT",
			action = act.AdjustPaneSize({ "Right", 3 }),
			description = "Resize pane right",
		},

		-- ========================
		-- Window
		-- ========================
		{
			key = "Enter",
			mods = "CTRL|SHIFT",
			action = act.ToggleFullScreen,
			description = "Toggle fullscreen (Ctrl+Shift)",
		},
		{
			key = "Enter",
			mods = "ALT",
			action = act.ToggleFullScreen,
			description = "Toggle fullscreen (Alt)",
		},
		{
			key = "n",
			mods = "CTRL|SHIFT",
			action = act.SpawnWindow,
			description = "Open new window",
		},

		-- ========================
		-- Clipboard
		-- ========================
		{
			key = "c",
			mods = "CTRL|SHIFT",
			action = act.CopyTo("Clipboard"),
			description = "Copy selection to clipboard",
		},
		{
			key = "v",
			mods = "CTRL|SHIFT",
			action = act.PasteFrom("Clipboard"),
			description = "Paste from clipboard",
		},

		-- ========================
		-- Config management
		-- ========================
		{
			key = "r",
			mods = "CTRL|SHIFT",
			action = act.ReloadConfiguration,
			description = "Reload configuration",
		},
		-- Command palette: discover all actions with descriptions.
		{
			key = "p",
			mods = "CTRL|SHIFT",
			action = act.ActivateCommandPalette,
			description = "Open command palette",
		},

		-- ========================
		-- Ctrl + Shift + F : Opacity toggle
		-- ========================
		{
			key = "F",
			mods = "CTRL|SHIFT",
			action = wezterm.action_callback(function(window, _)
				local overrides = window:get_config_overrides() or {}

				local base = platform.default_window_opacity()
				local transparent = transparent_opacity()

				if overrides.window_background_opacity == nil or overrides.window_background_opacity == base then
					-- Current is default → switch to transparent
					overrides.window_background_opacity = transparent
				else
					-- Current is transparent → restore default
					overrides.window_background_opacity = base
				end

				window:set_config_overrides(overrides)
			end),
			description = "Toggle window opacity (transparent ↔ default)",
		},
	}
end

return M
