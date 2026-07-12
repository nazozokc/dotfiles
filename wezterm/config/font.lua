-- Purpose: font stack and shaping options (1 responsibility: text rendering).

local wezterm = require("wezterm")
local platform = require("utils.platform")

local M = {}

function M.apply(config)
	-- Nerd Font is assumed (icons), and JetBrains Mono is readable at small sizes.
	-- Add a CJK fallback so Japanese text doesn't fall back to proportional fonts.
	-- Add per-platform system fonts as last-resort fallback.
	local font_family = "JetBrainsMono Nerd Font"
	local cjk_fallback = { family = "Noto Sans Mono CJK JP", weight = "Regular" }

	local system_fallback
	if platform.is_macos() then
		system_fallback = { family = "Menlo", weight = "Regular" }
	elseif platform.is_windows() then
		system_fallback = { family = "Cascadia Mono", weight = "Regular" }
	else
		system_fallback = { family = "Noto Sans Mono", weight = "Regular" }
	end

	config.font = wezterm.font_with_fallback({
		{ family = font_family, weight = "Regular" },
		cjk_fallback,
		system_fallback,
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
