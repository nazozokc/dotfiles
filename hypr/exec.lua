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
	-- hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")

	-- Network manager applet (if needed)
	-- hl.exec_cmd("nm-applet --indicator")

	-- Bluetooth tray (if needed)
	-- hl.exec_cmd("blueman-applet")
end)
