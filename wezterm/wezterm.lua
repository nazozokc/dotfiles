-- Purpose: entrypoint that only composes config modules.

local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.automatically_reload_config = true

require("config.appearance").apply(config)
require("config.font").apply(config)
require("config.keys").apply(config)
require("config.mouse").apply(config)
require("config.tab").apply(config)
require("config.performance").apply(config)

return config
