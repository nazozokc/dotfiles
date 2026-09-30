-- Autostart: launched once on Hyprland startup
-- https://wiki.hypr.land/Configuring/Basics/Autostart/

-- NOTE: Ambxst はここでは起動させない。
-- Ambxst 自身が出力する axctl.toml が `[startup] exec-once = "ambxst"` を
-- 持ち、生成された ~/.local/share/ambxst/hyprland.lua が
-- hl.on("hyprland.start", ...) で起動する (hyprland.lua の末尾で読み込む)。
-- ここにも書くと二重起動になり $XDG_RUNTIME_DIR/ambxst.sock が衝突する。

hl.on("hyprland.start", function()
	-- Japanese input (fcitx5)
	hl.exec_cmd("fcitx5 -d --replace")

	-- Polkit authentication agent
	-- Ambxst は polkit agent を同梱しないので必要
	hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
end)
