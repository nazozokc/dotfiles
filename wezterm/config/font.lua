-- Purpose: font stack and shaping options (1 responsibility: text rendering).

local wezterm = require("wezterm")
local platform = require("utils.platform")

local M = {}

function M.apply(config)
	-- Nerd Font is assumed (icons), and JetBrains Mono is readable at small sizes.
	-- Add per-platform system fonts as last-resort fallback.
	-- CJK on Windows: use a system font that ships with the OS rather than a large external one.
	local font_family = "JetBrainsMono Nerd Font"
	local system_fallback
	local cjk_fallback
	if platform.is_macos() then
		system_fallback = { family = "Menlo", weight = "Regular" }
		cjk_fallback = { family = "Noto Sans Mono CJK JP", weight = "Regular" }
	elseif platform.is_windows() then
		system_fallback = { family = "Cascadia Mono", weight = "Regular" }
		cjk_fallback = { family = "Yu Gothic UI", weight = "Regular" }
	else
		system_fallback = { family = "Noto Sans Mono", weight = "Regular" }
		cjk_fallback = { family = "Noto Sans Mono CJK JP", weight = "Regular" }
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
