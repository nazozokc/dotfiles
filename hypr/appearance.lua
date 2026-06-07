-- Look & feel: gaps, borders, decoration, animations
-- https://wiki.hypr.land/Configuring/Basics/Variables/

hl.config({
    -- General window management
    general = {
        gaps_in      = 3,
        gaps_out     = 5,
        border_size  = 2,

        col = {
            active_border   = { colors = { "rgba(cba6f7ee)", "rgba(89b4faee)" }, angle = 45 },
            inactive_border = "rgba(45475aee)",
        },

        layout = "dwindle",

        resize_on_border = false,
        allow_tearing    = false,
    },

    -- Window decorations: rounding, shadows, blur
    decoration = {
        rounding        = 10,
        rounding_power  = 2,
        active_opacity  = 1.0,
        inactive_opacity = 0.95,

        shadow = {
            enabled      = true,
            range        = 8,
            render_power = 3,
            color        = 0xee1a1a2e,
        },

        blur = {
            enabled           = true,
            size              = 8,
            passes            = 2,
            new_optimizations = true,
            ignore_opacity    = true,
            xray              = false,
        },
    },

    -- Animation globals
    animations = {
        enabled              = true,
        first_launch_animation = true,
    },

    -- Dwindle layout
    dwindle = {
        preserve_split = true,
    },

    -- Misc
    misc = {
        force_default_wallpaper = -1, -- disable the anime wallpaper
        disable_hyprland_logo   = false,
    },
})

-- Curves (bezier)
hl.curve("easeOutQuint",   { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear",         { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear",   { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick",          { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

-- Animation entries
hl.animation({ leaf = "global",        enabled = true,  speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true,  speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true,  speed = 4.79, spring = "default" })
hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 4.1,  spring = "default",         style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 1.49, bezier = "linear",           style = "popin 87%" })
hl.animation({ leaf = "fade",          enabled = true,  speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "workspaces",    enabled = true,  speed = 1.94, bezier = "almostLinear",     style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true,  speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true,  speed = 1.39, bezier = "almostLinear" })
