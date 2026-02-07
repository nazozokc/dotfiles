-- Purpose: tab bar behavior + title formatting (status visibility without visual noise).

local wezterm = require("wezterm")

local M = {}

local function basename(path)
  return (path:gsub("/$", ""):match("([^/]+)$")) or path
end

local function pane_cwd_basename(pane)
  -- Use environment variable as fallback when API is unavailable
  local cwd = os.getenv("PWD") or ""
  return basename(cwd)
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local pane = tab.active_pane
  local title = pane_cwd_basename(pane)

  -- SSH detection is disabled due to API compatibility issues

  local bg = tab.is_active and "#2D4F67" or "#181616"
  local fg = tab.is_active and "#C8C093" or "#c5c9c5"

  return {
    { Background = { Color = bg } },
    { Foreground = { Color = fg } },
    { Text = " " .. wezterm.truncate_right(title, max_width - 2) .. " " },
  }
end)

function M.apply(config)
  -- Tabs are useful for long-running shells; hide bar when it adds no information.
  config.enable_tab_bar = true
  config.hide_tab_bar_if_only_one_tab = true

  -- Fancy tab bar spends vertical space on decorations; we keep it compact.
  config.use_fancy_tab_bar = false
  config.show_tab_index_in_tab_bar = false

  config.tab_max_width = 25
end

return M
