-- Environment variables
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

-- Cursor
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Desktop environment detection
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- GTK: Wayland preferred, X11 fallback
hl.env("GDK_BACKEND", "wayland,x11")

-- Qt: Wayland preferred, XCB fallback
hl.env("QT_QPA_PLATFORM", "wayland;xcb")

-- SDL2
hl.env("SDL_VIDEODRIVER", "wayland")

-- Clutter (GNOME apps)
hl.env("CLUTTER_BACKEND", "wayland")

-- Java (fixes window reparenting)
hl.env("_JAVA_AWT_WM_NONREPARENTING", "1")
