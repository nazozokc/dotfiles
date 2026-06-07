-- Purpose: custom hyperlink rules for recognizing URLs, file paths, and issue references.
-- These rules are evaluated when you Ctrl+Shift+click (or use Quick Select) on text.
--
-- Note: the `format` field in hyperlink_rules must be a plain string template
-- (using $0, $1, $2, ...) since WezTerm 2025+.  Lua functions are no longer
-- accepted.  For editor-aware file:line opening we use a file:// URI with a
-- line-number fragment and intercept it via the open-uri event below.

local wezterm = require("wezterm")

local M = {}

function M.apply(config)
	-- Start with the built-in rules (URLs, email, etc.)
	config.hyperlink_rules = wezterm.default_hyperlink_rules()

	-- A single rule that handles multiple common patterns:
	--   - File:line:column  (e.g. src/main.rs:42:10)
	--   - File:line         (e.g. src/main.rs:42)
	-- Generates a file:// URI with the line number as a fragment so the
	-- open-uri handler below can open it in the user's editor.
	table.insert(config.hyperlink_rules, {
		regex = [[\b([\w./\\-]+\.\w+):(\d+)(?::(\d+))?\b]],
		format = "file://$1#$2",
	})
end

-- Intercept file:// URIs that carry a line-number fragment and open them
-- in the editor configured in EDITOR / VISUAL (default: vim).
wezterm.on("open-uri", function(window, pane, uri)
	if uri:find("^file:") then
		local url = wezterm.url.parse(uri)
		if url and url.file_path and url.fragment then
			local editor = os.getenv("EDITOR") or os.getenv("VISUAL") or "vim"
			pane:send_text(wezterm.shell_join_args({ editor, "+" .. url.fragment, url.file_path }) .. "\r")
			return false
		end
	end
end)

return M
