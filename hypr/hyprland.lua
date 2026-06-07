-- Hyprland configuration entry point
-- https://wiki.hypr.land/Configuring/Start/
--
-- Sub-configs are loaded via require().
-- Each file is a separate Lua scope, so errors in one don't affect others.

require("env")
require("monitors")
require("input")
require("appearance")
require("windowrules")
require("keybinds")
require("exec")
