-- Purpose: platform detection helpers to keep conditional logic out of config modules.

local wezterm = require("wezterm")

local M = {}

function M.is_linux()
	return wezterm.target_triple:find("linux") ~= nil
end

function M.is_macos()
	return wezterm.target_triple:find("apple") ~= nil
end

function M.is_windows()
	return wezterm.target_triple:find("windows") ~= nil
end

function M.is_wayland()
	-- WezTerm itself doesn't expose the display server directly; environment is the most reliable hint.
	return (os.getenv("WAYLAND_DISPLAY") ~= nil) or (os.getenv("XDG_SESSION_TYPE") == "wayland")
end

--- Return a recommended window background opacity for the current platform.
--- Wayland often has issues with transparent windows; on X11/Linux and other OSes it works fine.
function M.default_window_opacity()
	if M.is_linux() and M.is_wayland() then
		return 0.95
	end
	return 0.90
end

return M
