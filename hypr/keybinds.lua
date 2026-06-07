-- Keybindings: nvim + wezterm style
-- https://wiki.hypr.land/Configuring/Basics/Binds/
--
-- Design principles:
--   • $mainMod (= SUPER / Windows key) is the primary modifier,
--     akin to wezterm's Ctrl+Shift prefix.
--   • hjkl for window focus movement (vim/wezterm convention).
--   • Workspaces map to tabs (wezterm: Ctrl+Shift+[number/[/]]).
--   • $mainMod + q to close = wezterm's Ctrl+Shift+q.
--

local mainMod = "SUPER"

-- ═══════════════════════════════════════════════════════════
-- NAVIGATION (vim hjkl → focus direction)
-- ═══════════════════════════════════════════════════════════
-- wezterm:  Ctrl+Shift + h/j/k/l → pane focus
-- Hyprland: $mainMod   + h/j/k/l → window focus

hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))

-- ═══════════════════════════════════════════════════════════
-- WINDOW MANAGEMENT
-- ═══════════════════════════════════════════════════════════
-- wezterm:  Ctrl+Shift + q → close pane
-- Hyprland: $mainMod   + q → close window

hl.bind(mainMod .. " + Q",          hl.dsp.window.close())          -- close window
hl.bind(mainMod .. " + F",          hl.dsp.window.fullscreen())     -- toggle fullscreen
hl.bind(mainMod .. " + Space",      hl.dsp.window.float({ action = "toggle" }))  -- toggle float
hl.bind(mainMod .. " + V",          hl.dsp.window.pseudo())         -- toggle pseudo tiling (like nvim :vsp)
hl.bind(mainMod .. " + J",          hl.dsp.layout("togglesplit"))   -- toggle split direction (dwindle)

-- ═══════════════════════════════════════════════════════════
-- WORKSPACES (wezterm tabs)
-- ═══════════════════════════════════════════════════════════
-- wezterm:  Ctrl+Shift + number → switch tab
-- Hyprland: $mainMod   + number → switch workspace

for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i,             hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i,     hl.dsp.window.move({ workspace = i }))
end

-- Tab navigation: prev/next workspace
-- wezterm:  Ctrl+Shift + [ / ] → prev/next tab
hl.bind(mainMod .. " + bracketleft",  hl.dsp.focus({ workspace = "m-1" }))
hl.bind(mainMod .. " + bracketright", hl.dsp.focus({ workspace = "m+1" }))

-- ═══════════════════════════════════════════════════════════
-- LAUNCH
-- ═══════════════════════════════════════════════════════════
-- $mainMod + Return  → terminal (wezterm: Ctrl+Shift+t = new tab, analog)
-- $mainMod + d       → app launcher (rofi drun)
-- $mainMod + Shift+d → command runner (rofi run)

hl.bind(mainMod .. " + Return",     hl.dsp.exec_cmd("wezterm"))
hl.bind(mainMod .. " + D",          hl.dsp.exec_cmd("rofi -show drun"))
hl.bind(mainMod .. " + SHIFT + D",  hl.dsp.exec_cmd("rofi -show run"))

-- ═══════════════════════════════════════════════════════════
-- SCREENSHOT (grim + slurp + wl-clipboard)
-- ═══════════════════════════════════════════════════════════
-- Print           → region select → clipboard
-- Shift + Print   → full screen   → clipboard

hl.bind("Print",            hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy"))
hl.bind("SHIFT + Print",    hl.dsp.exec_cmd("grim - | wl-copy"))

-- ═══════════════════════════════════════════════════════════
-- SYSTEM
-- ═══════════════════════════════════════════════════════════
hl.bind(mainMod .. " + L",              hl.dsp.exec_cmd("hyprlock"))                  -- lock
hl.bind(mainMod .. " + SHIFT + L",      hl.dsp.exec_cmd("systemctl suspend"))         -- sleep
hl.bind(mainMod .. " + SHIFT + Q",      hl.dsp.exec_cmd("hyprctl dispatch exit"))     -- quit (nvim :q!)
hl.bind(mainMod .. " + SHIFT + Escape", hl.dsp.exec_cmd("wlogout"))                   -- logout menu

-- ═══════════════════════════════════════════════════════════
-- MOUSE
-- ═══════════════════════════════════════════════════════════
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- ═══════════════════════════════════════════════════════════
-- MEDIA KEYS
-- ═══════════════════════════════════════════════════════════
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),  { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),  { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86AudioNext",        hl.dsp.exec_cmd("playerctl next"),         { locked = true })
hl.bind("XF86AudioPause",       hl.dsp.exec_cmd("playerctl play-pause"),   { locked = true })
hl.bind("XF86AudioPlay",        hl.dsp.exec_cmd("playerctl play-pause"),   { locked = true })
hl.bind("XF86AudioPrev",        hl.dsp.exec_cmd("playerctl previous"),     { locked = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl set 5%+"),  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl set 5%-"),  { locked = true, repeating = true })
