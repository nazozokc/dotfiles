local platform = require("utils.platform")

local M = {}

function M.apply(config)
	config.max_fps = 120
	config.animation_fps = 1

	-- Software (DirectWrite) has the lowest input latency on Windows.
	-- "WebGpu" can be faster on a modern discrete GPU but often adds lag on integrated/driver-bound setups.
	config.front_end = "Software"

	config.scrollback_lines = 10000
	config.scroll_to_bottom_on_input = true
end

return M
