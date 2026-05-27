-- Purpose: Leader key (Ctrl+Shift+Space) and its sub-commands.
-- Includes Quick Select patterns and Workspace schemas.
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

	--------------
	-- Workspaces
	--------------
	config.workspace_schemas = {
		{ name = "default", label = "Default" },
	}

	--------------
	-- Quick Select patterns
	--------------
	-- Match URLs, file paths with line numbers, sha1 hashes, IP addresses.
	config.quick_select_patterns = {
		-- HTTP/HTTPS URLs
		"https?://\\S+",
		-- File paths with optional line:column suffix
		"\\b\\w+:\\d+(?::\\d+)?\\b",
		-- Git SHA / hex strings of 7+ chars
		"\\b[0-9a-f]{7,40}\\b",
		-- IPv4 addresses
		"\\b\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\b",
	}
end

return M
