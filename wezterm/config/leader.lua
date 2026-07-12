-- Purpose: Leader key (Ctrl+Shift+Space) and its sub-commands.
-- Includes Quick Select patterns and pane/tab management.
-- These live under Leader to avoid cluttering the main Ctrl+Shift namespace.

local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

function M.apply(config)
	----------
	-- Leader
	----------
	config.leader = { key = "Space", mods = "CTRL|SHIFT", timeout_ms = 2000 }

	config.keys = config.keys or {}

	-- Quick Select — pick visible text by keyboard
	table.insert(config.keys, {
		key = "Space",
		mods = "LEADER",
		action = act.QuickSelect,
	})

	-- Workspace switcher
	table.insert(config.keys, {
		key = "w",
		mods = "LEADER",
		action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }),
	})

	-- Quick workspace number keys (1-9)
	for i = 1, 9 do
		table.insert(config.keys, {
			key = tostring(i),
			mods = "LEADER",
			action = act.SwitchWorkspaceRelative(i - 1),
		})
	end

	-- PaneSelect: show numbered overlay, type index to jump (tmux display-panes style)
	table.insert(config.keys, {
		key = "q",
		mods = "LEADER",
		action = act.PaneSelect({ mode = "ActivateByIndex" }),
	})

	-- Rotate panes clockwise
	table.insert(config.keys, {
		key = "r",
		mods = "LEADER",
		action = act.RotatePanes("Clockwise"),
	})

	-- Rotate panes counter-clockwise (Shift+R)
	table.insert(config.keys, {
		key = "R",
		mods = "LEADER",
		action = act.RotatePanes("CounterClockwise"),
	})

	-- Detach current pane into a new tab
	table.insert(config.keys, {
		key = "p",
		mods = "LEADER",
		action = act.MovePaneToNewTab,
	})

	-- Rename current workspace via prompt
	table.insert(config.keys, {
		key = ",",
		mods = "LEADER",
		action = wezterm.action_callback(function(window, pane)
			local workspace = window:active_workspace()
			window:perform_action(
				act.PromptInputLine({
					description = "Enter new name for workspace '" .. workspace .. "'",
					initial_value = workspace,
					action = wezterm.action_callback(function(win, _, line)
						if line then
							win:perform_action(act.SwitchToWorkspace({ name = line }), pane)
						end
					end),
				}),
				pane
			)
		end),
	})

	--------------
	-- Quick Select patterns
	--------------
	-- Match URLs, file paths with line numbers, sha1 hashes, IP addresses,
	-- code symbols, and numeric values.
	config.quick_select_patterns = {
		-- HTTP/HTTPS URLs
		"https?://\\S+",
		-- File paths with optional line:column suffix
		"\\b\\w+:\\d+(?::\\d+)?\\b",
		-- Git SHA / hex strings of 7+ chars
		"\\b[0-9a-f]{7,40}\\b",
		-- IPv4 addresses
		"\\b\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\b",
		-- CamelCase symbols (class names, type names, etc.)
		"\\b[A-Z][a-z]+[A-Z][a-zA-Z0-9]*\\b",
		-- Numeric literals (integers and floats)
		"\\b\\d+\\.?\\d*\\b",
		-- Anchor references like file#L42 or file#42
		"[\\w./-]+#[Ll]?\\d+",
	}
end

return M
