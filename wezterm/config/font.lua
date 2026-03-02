-- Purpose: font stack and shaping options (1 responsibility: text rendering).

local wezterm = require("wezterm")

local M = {}

function M.apply(config)
  -- Nerd Font is assumed (icons), and JetBrains Mono is readable at small sizes.
  -- Add a CJK fallback so Japanese text doesn't fall back to proportional fonts.
  config.font = wezterm.font_with_fallback({
    { family = "JetBrainsMono Nerd Font", weight = "Regular" },
    { family = "Noto Sans Mono CJK JP", weight = "Regular" },
  })

  -- Fixed size keeps layout stable across windows and avoids accidental zoom.
  -- 13 is a practical default for ~96 DPI Linux desktops.
  config.font_size = 13.0

  -- Slightly tighter line height improves information density without touching glyphs.
  config.line_height = 1.05

  -- Keep standard ligatures on; they improve readability of common operators in code.
  config.harfbuzz_features = { "calt", "clig", "liga" }
end

return M
