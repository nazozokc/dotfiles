-- Purpose: small Linux-focused helpers to keep conditionals out of config modules.

local wezterm = require("wezterm")

local M = {}

function M.is_linux()
  return wezterm.target_triple:find("linux") ~= nil
end

function M.is_wayland()
  -- WezTerm itself doesn't expose the display server directly; environment is the most reliable hint.
  return (os.getenv("WAYLAND_DISPLAY") ~= nil) or (os.getenv("XDG_SESSION_TYPE") == "wayland")
end

return M
