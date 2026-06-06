-- Purpose: lightweight workspace session persistence.
-- Saves active workspace on config reload, restores on next startup.
-- This is intentionally simple: no mux server, no pane-layout serialization.

local wezterm = require("wezterm")

local STATE_KEY = "saved_workspace"

local M = {}

function M.apply(config)
	-- Save current workspace whenever config is reloaded (including on startup).
	wezterm.on("window-config-reloaded", function(window, _)
		local workspace = window:active_workspace()
		if workspace and workspace ~= "" then
			wezterm.state(STATE_KEY, workspace)
		end
	end)
end

-- Subscribe to gui-startup (fires only once per process; safe on config reload).
wezterm.on("gui-startup", function(cmd)
	local saved = wezterm.state(STATE_KEY)
	if saved and saved ~= "" and saved ~= "default" then
		cmd = cmd or {}
		cmd.workspace = saved
	end

	if cmd then
		wezterm.mux.spawn_window(cmd)
	end
	-- If cmd is nil, wezterm creates a default window automatically.
end)

return M
