local platform = require("utils.platform")

local M = {}

function M.apply(config)
	config.max_fps = 60
	config.animation_fps = 1

	-- OpenGL is more stable/faster on Windows; WebGPU on Linux/macOS.
	config.front_end = platform.is_windows() and "OpenGL" or "WebGpu"

	config.scrollback_lines = 10000
	config.scroll_to_bottom_on_input = true
end

return M
