-- Purpose: visuals only (colors, padding, decorations). Keep it calm and information-dense.

local platform = require("utils.platform")

local M = {}

function M.apply(config)
	-- A dark background reduces eye strain in long CLI sessions.
	config.colors = {
		foreground = "#c5c9c5",
		background = "#181616",

		-- Cursor/selection must be visible but not neon.
		cursor_bg = "#C8C093",
		cursor_fg = "#181616",
		cursor_border = "#C8C093",

		selection_fg = "#C8C093",
		selection_bg = "#2D4F67",

		-- A full ANSI palette prevents "random default colors" that can clash with our background.
		ansi = { "#0D0C0C", "#C4746E", "#8A9A7B", "#C4B28A", "#8BA4B0", "#A292A3", "#8EA4A2", "#C8C093" },
		brights = { "#A6A69C", "#E46876", "#87A987", "#E6C384", "#7FB4CA", "#938AA9", "#7AA89F", "#C5C9C5" },
		indexed = { [16] = "#B6927B", [17] = "#B98D7B" },

		split = "#2a2a2a",
	}

	-- Platform-aware transparency.
	-- Wayland compositors vary in transparency support; use a slightly less aggressive value there.
	config.window_background_opacity = platform.default_window_opacity()
	config.text_background_opacity = 1.0

	-- Minimal chrome: resize handles only (keep title bar on macOS for traffic-light buttons).
	if platform.is_macos() then
		config.window_decorations = "TITLE|RESIZE"
	else
		config.window_decorations = "RESIZE"
	end

	-- Small padding keeps text off the window edges without wasting screen real estate.
	config.window_padding = {
		left = 6,
		right = 6,
		top = 4,
		bottom = 4,
	}

	config.enable_scroll_bar = false
	config.adjust_window_size_when_changing_font_size = false

	-- WezTerm should behave like a config-file tool; updates are handled by the OS package manager.
	config.check_for_updates = false
	config.automatically_reload_config = true

	-- Explicitly set terminfo name; keeps term-dependent behavior predictable.
	config.term = "wezterm"

	-- Dim inactive panes so your focus stays on the active one.
	config.inactive_pane_hsb = { saturation = 0.3, brightness = 0.4 }

	-- Window frame colours (RESIZE-only on Linux/Win, full title bar on macOS).
	-- These make the window border blend with the background scheme.
	config.window_frame = {
		active_titlebar_bg = "#181616",
		inactive_titlebar_bg = "#0D0C0C",
	}

	-- Tab bar background and tab colours (used even with use_fancy_tab_bar = false).
	config.colors.tab_bar = {
		background = "#0D0C0C",
		active_tab = { bg_color = "#2D4F67", fg_color = "#C8C093" },
		inactive_tab = { bg_color = "#181616", fg_color = "#c5c9c5" },
		inactive_tab_hover = { bg_color = "#1e1c1c", fg_color = "#c5c9c5" },
	}

	-- IME is useful for Japanese input even when most work is in ASCII.
	config.use_ime = true
end

return M
