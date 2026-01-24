-- ============================================
-- WezTerm 生産性重視設定
-- カラースキーム: Kanagawa (Gogh) 維持
-- ============================================

local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux

local config = wezterm.config_builder()

-- ======================
-- 変数管理
-- ======================
local opacity = 1.0
local ligature_enabled = true

-- ======================
-- 起動時フルスクリーン
-- ======================
wezterm.on("gui-startup", function(cmd)
  local _, _, window = mux.spawn_window(cmd or {})
  window:gui_window():toggle_fullscreen()
end)

-- ======================
-- 基本
-- ======================
config.term = "wezterm"
config.check_for_updates = false
config.use_ime = true
config.automatically_reload_config = true

-- ======================
-- フォント（視認性重視）
-- ======================
config.font = wezterm.font_with_fallback({
  {
    family = "JetBrainsMono Nerd Font",
    weight = "Regular",
  },
  {
    family = "Noto Sans Mono CJK JP",
    weight = "Regular",
  },
})
config.font_size = 13.5
config.line_height = 1.05
config.cell_width = 1.0
config.harfbuzz_features = { "calt", "clig", "liga" }

-- ======================
-- カラースキーム（Kanagawa維持）
-- ======================
config.color_scheme = "Kanagawa (Gogh)"
config.colors = {
  foreground = "#c5c9c5",
  background = "#181616",

  cursor_bg = "#C8C093",
  cursor_fg = "#2D4F67",
  cursor_border = "#C8C093",

  selection_fg = "#C8C093",
  selection_bg = "#2D4F67",

  scrollbar_thumb = "#16161D",
  split = "#16161D",

  ansi = { "#0D0C0C", "#C4746E", "#8A9A7B", "#C4B28A", "#8BA4B0", "#A292A3", "#8EA4A2", "#C8C093" },
  brights = { "#A6A69C", "#E46876", "#87A987", "#E6C384", "#7FB4CA", "#938AA9", "#7AA89F", "#C5C9C5" },
  indexed = { [16] = "#B6927B", [17] = "#B98D7B" },
}
-- ======================
-- 透過・見た目
-- ======================
config.window_background_opacity = 1.0
config.text_background_opacity = 1.0
config.window_decorations = "RESIZE"
config.window_padding = {
  left = 6,
  right = 6,
  top = 4,
  bottom = 4,
}
config.adjust_window_size_when_changing_font_size = false
config.enable_scroll_bar = false

-- ======================
-- タブ（コンパクト）
-- ======================
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_max_width = 25
config.show_tab_index_in_tab_bar = false

-- ======================
-- パフォーマンス
-- ======================
config.max_fps = 60
config.animation_fps = 1 -- 1から60に変更（スムーズなアニメーション）
config.front_end = "WebGpu"

-- ======================
-- スクロール
-- ======================
config.scrollback_lines = 10000
config.enable_kitty_graphics = true
config.scroll_to_bottom_on_input = true

-- ======================
-- キーバインド（生産性重視）
-- ======================
config.keys = {
  -- タブ操作
  { key = "t",        mods = "CTRL|SHIFT", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "w",        mods = "CTRL|SHIFT", action = act.CloseCurrentTab({ confirm = true }) },
  { key = "h",        mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },
  { key = "l",        mods = "CTRL|SHIFT", action = act.ActivateTabRelative(1) },
  { key = "1",        mods = "CTRL",       action = act.ActivateTab(0) },
  { key = "2",        mods = "CTRL",       action = act.ActivateTab(1) },
  { key = "3",        mods = "CTRL",       action = act.ActivateTab(2) },
  { key = "4",        mods = "CTRL",       action = act.ActivateTab(3) },
  { key = "5",        mods = "CTRL",       action = act.ActivateTab(4) },
  { key = "6",        mods = "CTRL",       action = act.ActivateTab(5) },
  { key = "7",        mods = "CTRL",       action = act.ActivateTab(6) },
  { key = "8",        mods = "CTRL",       action = act.ActivateTab(7) },
  { key = "9",        mods = "CTRL",       action = act.ActivateTab(8) },
  { key = "0",        mods = "CTRL",       action = act.ActivateTab(-1) },

  -- ウィンドウ操作
  { key = "Enter",    mods = "ALT",        action = act.ToggleFullScreen },
  { key = "n",        mods = "CTRL|SHIFT", action = act.SpawnWindow },

  -- ペイン分割
  { key = "e",        mods = "CTRL|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "d",        mods = "CTRL|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

  -- ペイン移動（Vim風 + ALT）
  { key = "h",        mods = "ALT",        action = act.ActivatePaneDirection("Left") },
  { key = "l",        mods = "ALT",        action = act.ActivatePaneDirection("Right") },
  { key = "k",        mods = "ALT",        action = act.ActivatePaneDirection("Up") },
  { key = "j",        mods = "ALT",        action = act.ActivatePaneDirection("Down") },

  -- ペインリサイズ（CTRL+ALT + h/j/k/l）
  { key = "h",        mods = "CTRL|ALT",   action = act.AdjustPaneSize { "Left", 3 } },
  { key = "l",        mods = "CTRL|ALT",   action = act.AdjustPaneSize { "Right", 3 } },
  { key = "k",        mods = "CTRL|ALT",   action = act.AdjustPaneSize { "Up", 3 } },
  { key = "j",        mods = "CTRL|ALT",   action = act.AdjustPaneSize { "Down", 3 } },

  -- ペイン閉じる
  { key = "q",        mods = "CTRL|SHIFT", action = act.CloseCurrentPane({ confirm = true }) },

  -- クリップボード
  { key = "c",        mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
  { key = "v",        mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },
  { key = "x",        mods = "CTRL|SHIFT", action = act.CopyTo("PrimarySelection") },

  -- スクロール
  { key = "PageUp",   mods = "SHIFT",      action = act.ScrollByPage(-1) },
  { key = "PageDown", mods = "SHIFT",      action = act.ScrollByPage(1) },
  { key = "Home",     mods = "SHIFT",      action = act.ScrollToTop },
  { key = "End",      mods = "SHIFT",      action = act.ScrollToBottom },

  -- クイック開始（Launcher）
  { key = "p",        mods = "CTRL|SHIFT", action = act.ActivateCommandPalette },
  { key = "r",        mods = "CTRL|SHIFT", action = act.ReloadConfiguration },

  -- 透過トグル
  {
    key = "f",
    mods = "CTRL|SHIFT",
    action = wezterm.action_callback(function(window, pane)
      opacity = opacity == 1.0 and 0.75 or 1.0
      window:set_config_overrides({
        window_background_opacity = opacity,
        text_background_opacity = opacity,
      })
    end)
  },

  -- Ligatureトグル
  {
    key = "g",
    mods = "CTRL|SHIFT",
    action = wezterm.action_callback(function(window, pane)
      ligature_enabled = not ligature_enabled
      local overrides = window:get_config_overrides() or {}
      if ligature_enabled then
        overrides.harfbuzz_features = nil
      else
        overrides.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }
      end
      window:set_config_overrides(overrides)
    end)
  },

  -- ワークスペース
  { key = "[", mods = "CTRL|SHIFT", action = act.SwitchWorkspaceRelative(-1) },
  { key = "]", mods = "CTRL|SHIFT", action = act.SwitchWorkspaceRelative(1) },
  { key = "{", mods = "CTRL|SHIFT", action = act.SwitchToWorkspace },
}

-- マウスバインド（右クリックでコピー）
config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = "Right" } },
    mods = "NONE",
    action = act.CompleteSelection("Clipboard"),
  },
  {
    event = { Up = { streak = 1, button = "Right" } },
    mods = "NONE",
    action = act.PasteFrom("Clipboard"),
  },
}

-- ======================
-- タブタイトル（SSH先強化）
-- ======================
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local pane = tab.active_pane
  local title = ""

  -- ディレクトリ取得
  local cwd_uri = pane:get_current_working_dir()
  local cwd = cwd_uri and cwd_uri.file_path or ""
  local repo = cwd:match("([^/]+)$") or cwd

  -- SSH判定
  local domain = pane:get_domain_name()
  if domain and domain ~= "local" then
    local host = domain:gsub("^SSH:", "")
    title = string.format("[%s] %s", host, repo)
  else
    title = repo
  end

  -- SSH server 側
  local vars = pane:get_user_vars()
  if vars.IS_SSH_SERVER == "1" then
    local client = vars.SSH_CLIENT_HOST or "unknown"
    return {
      { Background = { Color = "#f7768e" } },
      { Foreground = { Color = "#0a0a0a" } },
      { Attribute = { Intensity = "Bold" } },
      { Text = " [INCOMING SSH] " .. client .. " " .. repo .. " " },
    }
  end

  return {
    { Text = " " .. title .. " " },
  }
end)

return config
