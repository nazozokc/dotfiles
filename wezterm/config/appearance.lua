-- Purpose: visuals only (colors, padding, decorations). Keep it calm and information-dense.

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

  -- No aggressive transparency: readable in all lighting and avoids compositing overhead.
  config.window_background_opacity = 1.0
  config.text_background_opacity = 1.0

  -- Minimal chrome: resize handles only.
  config.window_decorations = "RESIZE"

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

  -- IME is useful for Japanese input even when most work is in ASCII.
  config.use_ime = true
end

return M
