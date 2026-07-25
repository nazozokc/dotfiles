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

-- Blur behind waybar (requires waybar with transparent background)
hl.layer_rule({ name = "blur-waybar", match = { namespace = "waybar" }, blur = true })
-- Ignore fully transparent pixels so only content areas get blurred
hl.layer_rule({ name = "ignorezero-waybar", match = { namespace = "waybar" }, ignore_alpha = 0.5 })

-- Blur behind rofi launcher
hl.layer_rule({ name = "blur-rofi", match = { namespace = "rofi" }, blur = true, ignore_alpha = 0.5 })
