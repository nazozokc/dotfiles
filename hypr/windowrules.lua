-- Window and workspace rules
-- https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Suppress maximize events — prevents apps from force-maximizing on you
hl.window_rule({
	name = "suppress-maximize-events",
	match = { class = ".*" },
	suppress_event = "maximize",
})

-- Fix XWayland drag issues
hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},
	no_focus = true,
})

-- Float these by default
local floatClasses = {
	"pavucontrol",
	"blueman-manager",
	"org.gnome.Calculator",
	"org.gnome.NautilusPreferences",
	"mpv",
	"xdg-desktop-portal",
}

for _, class in ipairs(floatClasses) do
	hl.window_rule({
		name = "float-" .. class,
		match = { class = "^" .. class .. "$" },
		float = true,
	})
end

-- ═══════════════════════════════════════════════════════════
-- VISUAL EFFECTS
-- ═══════════════════════════════════════════════════════════

-- Dim background for floating windows (focus assist)
hl.window_rule({
	name = "dim-floating",
	match = { float = true },
	dim_around = true,
})

-- Terminal windows: subtle opacity for layered depth
hl.window_rule({
	name = "wezterm-opacity",
	match = { class = "^wezterm$" },
	opacity = "0.95 override 0.90 override",
})

hl.window_rule({
	name = "kitty-opacity",
	match = { class = "^kitty$" },
	opacity = "0.95 override 0.90 override",
})

-- ═══════════════════════════════════════════════════════════
-- LAYER RULES (bars, launchers, etc.)
-- ═══════════════════════════════════════════════════════════

-- 旧: blur-waybar / ignorezero-waybar / blur-rofi
-- Ambxst は bar・launcher・notification・wallpaper を自分の layer surface
-- (namespace `quickshell` / `ambxst*`) として持ち、layer rule も
-- 生成された hyprland.lua に書く。そのためこの rule は不要。
