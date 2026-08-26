local platform = require("utils.platform")

local M = {}

function M.apply(config)
	config.max_fps = 120
	config.animation_fps = 1

	-- OpenGL avoids the slow software-rendering path on Windows.
	-- Keep the existing software backend on other platforms until their rendering
	-- configuration is evaluated independently.
	if platform.is_windows() then
		config.front_end = "OpenGL"
	else
		config.front_end = "Software"
	end

	config.scrollback_lines = 10000
	config.scroll_to_bottom_on_input = true
end

return M
