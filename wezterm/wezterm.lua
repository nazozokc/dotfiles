-- Purpose: entrypoint that only composes config modules.

local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- Order matters: keys/leader must come after basic setup.
require("config.appearance").apply(config)
require("config.font").apply(config)
require("config.performance").apply(config)
require("config.hyperlinks").apply(config)
require("config.launch_menu").apply(config)
require("config.tab").apply(config)
require("config.status").apply(config)
require("config.leader").apply(config)
require("config.keys").apply(config)
require("config.mouse").apply(config)

-- Session is loaded last so its event registrations don't interfere with config keys.
require("config.session").apply(config)

return config
