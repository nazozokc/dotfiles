-- Window and workspace rules
-- https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Suppress maximize events — prevents apps from force-maximizing on you
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix XWayland drag issues
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
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
        name   = "float-" .. class,
        match  = { class = "^" .. class .. "$" },
        float  = true,
    })
end
