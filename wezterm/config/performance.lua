local platform = require("utils.platform")

local M = {}

function M.apply(config)
	config.max_fps = 60
	config.animation_fps = 1

	-- OpenGL is more stable than WebGPU on real-world Windows GPU/driver combos.
	-- Swap to "WebGpu" if you have a newer GPU that handles it well, or "Software" if still stuttering.
	config.front_end = "OpenGL"

	config.scrollback_lines = 10000
	config.scroll_to_bottom_on_input = true
end

return M
