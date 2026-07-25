-- Autostart: launched once on Hyprland startup
-- https://wiki.hypr.land/Configuring/Basics/Autostart/

hl.on("hyprland.start", function()
	-- Status bar
	hl.exec_cmd("waybar")

	-- Wallpaper (swww)
	hl.exec_cmd("swww init")
	-- Uncomment and set your wallpaper path:
	-- hl.exec_cmd("swww img ~/Pictures/wallpapers/current")

	-- Japanese input (fcitx5)
	hl.exec_cmd("fcitx5 -d --replace")

	-- Polkit authentication agent
	hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")

	-- Notification daemon
	hl.exec_cmd("dunst")

	-- Idle manager
	hl.exec_cmd("hypridle")
end)
