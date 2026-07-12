-- Purpose: keyboard-only window/pane/tab control. No tmux-style prefix, no Ctrl-alone binds.
-- All keybindings have description for command palette discoverability.
-- macOS gets SUPERSET bindings (SUPER/Cmd equivalents) so muscle memory isn't broken.

local wezterm = require("wezterm")
local platform = require("utils.platform")
local act = wezterm.action

local M = {}

--- Opacity levels cycled by Ctrl+Shift+F:
---   1. opaque (1.0)
---   2. default (platform-aware: 0.95 on Wayland, 0.90 elsewhere)
---   3. transparent (default - 0.15, floor 0.60)
local OPACITY_LEVELS

local function init_opacity_levels()
	local base = platform.default_window_opacity()
	OPACITY_LEVELS = {
		opaque       = 1.0,
		default      = base,
		transparent  = math.max(base - 0.15, 0.60),
	}
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
		-- Bracket-based nav: Vim-mnemonic ([ = prev, ] = next).
		-- Neither Ctrl+Shift+[ nor Ctrl+Shift+] conflicts with nvim.
		-- Keep PageUp/Down as fallback for non-US layouts where [ ] may be awkward.
		{
			key = "[",
			mods = "CTRL|SHIFT",
			action = act.ActivateTabRelative(-1),
			description = "Activate previous tab",
		},
		{
			key = "]",
			mods = "CTRL|SHIFT",
			action = act.ActivateTabRelative(1),
			description = "Activate next tab",
		},
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
		-- Ctrl + Shift + F : Opacity cycle (opaque → default → transparent → ...)
		-- ========================
		{
			key = "F",
			mods = "CTRL|SHIFT",
			action = wezterm.action_callback(function(window, _)
				if not OPACITY_LEVELS then
					init_opacity_levels()
				end

				local overrides = window:get_config_overrides() or {}
				local current = overrides.window_background_opacity
					or platform.default_window_opacity()

				-- Cycle forward through the three levels
				local next_val
				if current == OPACITY_LEVELS.opaque then
					next_val = OPACITY_LEVELS.default
				elseif current == OPACITY_LEVELS.default then
					next_val = OPACITY_LEVELS.transparent
				else
					next_val = OPACITY_LEVELS.opaque
				end

				overrides.window_background_opacity = next_val
				window:set_config_overrides(overrides)
			end),
			description = "Cycle window opacity: opaque → default → transparent",
		},
	}

	-- ========================
	-- macOS SUPER (Cmd) bindings (appended only on macOS)
	-- ========================
	-- macOS WM reserves Cmd+W (close window) and Cmd+Q (quit) natively.
	if platform.is_macos() then
		local mac_keys = {
			{
				key = "t",
				mods = "SUPER",
				action = act.SpawnTab("CurrentPaneDomain"),
				description = "Open new tab",
			},
			{
				key = "c",
				mods = "SUPER",
				action = act.CopyTo("Clipboard"),
				description = "Copy selection to clipboard",
			},
			{
				key = "v",
				mods = "SUPER",
				action = act.PasteFrom("Clipboard"),
				description = "Paste from clipboard",
			},
			{
				key = "n",
				mods = "SUPER",
				action = act.SpawnWindow,
				description = "Open new window",
			},
			{
				key = "Enter",
				mods = "SUPER|CTRL",
				action = act.ToggleFullScreen,
				description = "Toggle fullscreen",
			},
		}
		for _, k in ipairs(mac_keys) do
			table.insert(config.keys, k)
		end
	end
end

return M
