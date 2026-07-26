-- Purpose: lightweight workspace session persistence.
-- Saves active workspace on config reload, restores on next startup.
-- This is intentionally simple: no mux server, no pane-layout serialization.
-- Uses a JSON file in the config directory (wezterm.state does not exist in the Lua API).

local wezterm = require("wezterm")

local STATE_FILE = wezterm.config_dir .. "/.workspace_state.json"

local M = {}

local function read_state()
	local f, err = io.open(STATE_FILE, "r")
	if not f then
		return nil
	end
	local content = f:read("*a")
	f:close()
	if content and content ~= "" then
		local ok, decoded = pcall(wezterm.json_decode, content)
		if ok and type(decoded) == "table" and decoded.workspace then
			return decoded.workspace
		end
	end
	return nil
end

local function write_state(workspace)
	local f, err = io.open(STATE_FILE, "w")
	if not f then
		return
	end
	f:write(wezterm.json_encode({ workspace = workspace }))
	f:close()
end

function M.apply(config)
	-- Save current workspace whenever config is reloaded (including on startup).
	wezterm.on("window-config-reloaded", function(window, _)
		local workspace = window:active_workspace()
		if workspace and workspace ~= "" then
			write_state(workspace)
		end
	end)
end

-- Subscribe to gui-startup (fires only once per process; safe on config reload).
wezterm.on("gui-startup", function(cmd)
	local saved = read_state()
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
