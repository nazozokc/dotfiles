local platform = require("utils.platform")

local M = {}

function M.apply(config)
	config.max_fps = 60
	config.animation_fps = 1

	-- WebGPU > OpenGL on Windows; Windows OpenGL drivers are trash.
	-- Swap to "Software" if your GPU still stutters.
	config.front_end = "WebGpu"

	config.scrollback_lines = 10000
	config.scroll_to_bottom_on_input = true
end

return M
