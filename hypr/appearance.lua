-- Look & feel: gaps, borders, decoration, animations
-- https://wiki.hypr.land/Configuring/Basics/Variables/
--
-- Ambxst との役割分担:
--   Ambxst は生成した hyprland.lua で hl.config() を発行し、以下を常に
--   上書きする。ここに同じキーを書いても hyprland.lua 末尾で読み込まれる
--   Ambxst 側が後勝ちするため無効。
--
--     general.gaps_in / gaps_out / border_size
--     general.col.active_border / col.inactive_border
--     general.layout
--     decoration.rounding / active_opacity / inactive_opacity
--     decoration.shadow.*  decoration.blur.*
--     animations.enabled
--
--   見た目は Ambxst のテーマ設定 (~/.config/ambxst/config/compositor.json
--   と theme.json) で管理する。bar / border / blur / shadow / gaps は
--   Ambxst 起動中の変更がそのまま hyprctl に live 反映される。
--
--   このファイルには「Ambxst が触らない項目」だけを残している。

hl.config({
	-- General window management (Ambxst が触らないキーのみ)
	general = {
		resize_on_border = false,
		allow_tearing = false,
	},

	-- Window decorations (Ambxst が触らないキーのみ)
	decoration = {
		rounding_power = 2,
	},

	-- animations セクションはここでは書かない。
	-- v0.50 までは animations:first_launch_animation があったが v0.51 で削除され、
	-- 現在 (0.56) の残りは animations:enabled / workspace_wraparound のみ。
	-- enabled は「Ambxst が触らないキー」に該当しないので書かない。
	-- このキーを残すと unknown config key "animations.first_launch_animation" になる。

	-- Dwindle layout
	dwindle = {
		preserve_split = true,
	},

	-- Misc
	misc = {
		force_default_wallpaper = -1, -- disable the anime wallpaper
		disable_hyprland_logo = true,

		-- DPMS: wake on mouse/key
		mouse_move_enables_dpms = true,
		key_press_enables_dpms = true,

		-- Smooth window dragging
		animate_mouse_windowdragging = true,

		-- Terminal swallow: wezterm hides when launching GUI apps
		enable_swallow = true,
		swallow_regex = "^(wezterm)$",
	},
})

-- Curves (bezier)
-- NOTE: Ambxst は border / fade / windows / workspaces の 4 leaf を
-- 自分の myBezier で上書きする。ここで定義した curve のうち
-- 使われるのは global / windowsIn / windowsOut / fadeLayersIn /
-- fadeLayersOut の 5 leaf のみ。
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })
hl.curve("easeOutBack", { type = "bezier", points = { { 0.34, 1.56 }, { 0.64, 1 } } })
hl.curve("easeOutExpo", { type = "bezier", points = { { 0.19, 1 }, { 0.22, 1 } } })

-- Animation entries
-- NOTE: border / fade / workspaces / windows は Ambxst が上書きするため、
-- ここでは Ambxst が書かない leaf だけを定義する。
hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutBack", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
