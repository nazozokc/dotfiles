-- Purpose: tab bar behavior + title formatting (status visibility without visual noise).

local wezterm = require("wezterm")

local M = {}

local function basename(path)
  return (path:gsub("/$", ""):match("([^/]+)$")) or path
end

local function pane_cwd_basename(pane)
  local cwd_uri = pane:get_current_working_dir()
  if not cwd_uri then
    return ""
  end

  -- Newer WezTerm returns a Url object; file_path is the most direct representation.
  local cwd = cwd_uri.file_path or ""
  return basename(cwd)
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local pane = tab.active_pane
  local title = pane_cwd_basename(pane)

  -- If this pane is an SSH domain, make it explicit but subtle.
  local domain = pane:get_domain_name()
  if domain and domain ~= "local" then
    local host = domain:gsub("^SSH:", "")
    title = string.format("%s:%s", host, title)
  end

  -- Emphasize the truly important case: incoming SSH session (server-side terminal).
  local vars = pane:get_user_vars()
  if vars.IS_SSH_SERVER == "1" then
    local client = vars.SSH_CLIENT_HOST or "unknown"
    title = string.format("SSH<-%s:%s", client, title)
    return {
      { Background = { Color = "#C4746E" } },
      { Foreground = { Color = "#181616" } },
      { Attribute = { Intensity = "Bold" } },
      { Text = " " .. wezterm.truncate_right(title, max_width - 2) .. " " },
    }
  end

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
