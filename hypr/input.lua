-- Input configuration (keyboard, touchpad, mouse)
-- https://wiki.hypr.land/Configuring/Basics/Variables/#input

hl.config({
	input = {
		-- US keyboard layout; Win+Space switches between layouts (for fcitx5)
		kb_layout = "us",
		kb_variant = "",
		kb_options = "grp:win_space_toggle",

		follow_mouse = 1,
		mouse_refocus = false,
		sensitivity = 0, -- -1.0 to 1.0, 0 = no adjustment

		touchpad = {
			natural_scroll = true,
			disable_while_typing = true,
			clickfinger_behavior = true,
			tap_to_click = true,
		},
	},
})

-- Three-finger swipe for workspace switching
hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})
