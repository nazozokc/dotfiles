local platform = require("utils.platform")

local M = {}

function M.apply(config)
	config.max_fps = 120
	config.animation_fps = 30

	-- OpenGL avoids the slow software-rendering path on Windows/Linux.
	-- Keep Software on macOS for now (avoids driver quirks on some GPUs).
	if platform.is_windows() or platform.is_linux() then
		config.front_end = "OpenGL"
	else
		config.front_end = "Software"
	end

	config.scrollback_lines = 10000
	config.scroll_to_bottom_on_input = true
end

return M
