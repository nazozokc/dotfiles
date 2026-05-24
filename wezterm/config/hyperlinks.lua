-- Purpose: custom hyperlink rules for recognizing URLs, file paths, and issue references.
-- These rules are evaluated when you Ctrl+Shift+click (or use Quick Select) on text.

local wezterm = require("wezterm")

local M = {}

function M.apply(config)
	-- Start with the built-in rules (URLs, email, etc.)
	config.hyperlink_rules = wezterm.default_hyperlink_rules()

	-- A single rule that handles multiple common patterns:
	--   - File:line:column  (e.g. src/main.rs:42:10)
	--   - File:line         (e.g. src/main.rs:42)
	--   - File(line)        (e.g. src/main.rs(42))
	-- Opens the file in the editor configured in EDITOR/VISUAL (default: cursor at line).
	table.insert(config.hyperlink_rules, {
		regex = [[\b([\w./\\-]+\.\w+):(\d+)(?::(\d+))?\b]],
		format = function(uri)
			local file, line, col = uri:match([[\b([\w./\\-]+\.\w+):(\d+)(?::(\d+))?\b]])
			local editor = os.getenv("EDITOR") or os.getenv("VISUAL") or "vim"
			return string.format("%s +%s %s", editor, col and line or line or "1", file)
		end,
	})
end

return M
