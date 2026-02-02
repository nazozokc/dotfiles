-- Purpose: performance and responsiveness (no eye-candy; keep it light).

local M = {}

function M.apply(config)
  -- 60fps is enough for smooth cursor movement; higher fps just burns power.
  config.max_fps = 60

  -- Keep window animations essentially off; terminal UX should be immediate, not cinematic.
  config.animation_fps = 1

  -- WebGPU is typically the most efficient renderer on modern Linux.
  config.front_end = "WebGpu"

  -- Big enough for searching recent output; not so big that it becomes a memory sink.
  config.scrollback_lines = 10000

  -- Prevent the common "I typed but nothing changed" confusion when scrolled up.
  config.scroll_to_bottom_on_input = true
end

return M
