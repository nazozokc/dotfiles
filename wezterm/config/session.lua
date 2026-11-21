-- Purpose: lightweight workspace session persistence.
-- Saves the active workspace whenever it changes, restores on next startup.
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

-- WezTerm exposes no window-close/gui-shutdown event with workspace context,
-- so persist on change instead. update-status ticks often; the in-memory guard
-- keeps actual file writes rare.
local last_saved_workspace = nil

local function save_workspace(workspace)
	if not workspace or workspace == "" or workspace == last_saved_workspace then
		return
	end
	write_state(workspace)
	last_saved_workspace = workspace
end

function M.apply(config)
	-- Startup and config reload.
	wezterm.on("window-config-reloaded", function(window, _)
		save_workspace(window:active_workspace())
	end)

	-- Covers every switch path (launcher, number keys, relative switches).
	-- The last switch is already on disk before the app exits.
	wezterm.on("update-status", function(window, _)
		save_workspace(window:active_workspace())
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
