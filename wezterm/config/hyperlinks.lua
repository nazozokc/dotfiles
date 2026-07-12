-- Purpose: custom hyperlink rules for recognizing URLs, file paths, and issue references.
-- These rules are evaluated when you Ctrl+Shift+click (or use Quick Select) on text.
--
-- Note: the `format` field in hyperlink_rules must be a plain string template
-- (using $0, $1, $2, ...) since WezTerm 2025+.  Lua functions are no longer
-- accepted.  For editor-aware file:line opening we use a file:// URI with a
-- line-number fragment and intercept it via the open-uri event below.

local wezterm = require("wezterm")
local platform = require("utils.platform")

local M = {}

function M.apply(config)
	-- Start with the built-in rules (URLs, email, etc.)
	config.hyperlink_rules = wezterm.default_hyperlink_rules()

	-- A single rule that handles multiple common patterns:
	--   - File:line:column  (e.g. src/main.rs:42:10)
	--   - File:line         (e.g. src/main.rs:42)
	-- On Windows, also matches absolute paths with drive letters (e.g. C:\path\to\file.rs:42).
	-- Generates a file:// URI with the line number as a fragment so the
	-- open-uri handler below can open it in the user's editor.
	table.insert(config.hyperlink_rules, {
		regex = [[\b([\w./\\-]+\.\w+):(\d+)(?::(\d+))?\b]],
		format = "file://$1#$2",
	})
end

-- Normalize a path extracted from a file:// URI for the current platform.
-- On Windows, backslashes become forward slashes and drive-letter paths are
-- converted to /drive:/path format for editor compatibility.
local function normalize_file_path(path)
	if platform.is_windows() then
		-- Replace backslashes with forward slashes
		local normalized = path:gsub("\\", "/")
		-- Ensure drive letter is followed by colon for editor +N argument
		-- e.g., "C:/Users/..." stays as-is
		return normalized
	end
	return path
end

-- Intercept file:// URIs that carry a line-number fragment and open them
-- in the editor configured in EDITOR / VISUAL (default: vim).
wezterm.on("open-uri", function(window, pane, uri)
	if uri:find("^file:") then
		local url = wezterm.url.parse(uri)
		if url and url.file_path and url.fragment then
			local editor = os.getenv("EDITOR") or os.getenv("VISUAL") or "vim"
			local file_path = normalize_file_path(url.file_path)
			pane:send_text(wezterm.shell_join_args({ editor, "+" .. url.fragment, file_path }) .. "\r")
			return false
		end
	end
end)

return M
