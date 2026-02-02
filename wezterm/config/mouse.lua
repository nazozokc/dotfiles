-- Purpose: mouse is allowed only for selection and scrolling; no right-click paste, no link opening.

local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

function M.apply(config)
  -- Enforce a minimal mouse surface area: selection + wheel scroll.
  config.disable_default_mouse_bindings = true

  -- When an app enables mouse reporting (e.g. nvim with mouse), holding Shift should bypass it
  -- so you can still select/copy from the terminal without fighting the app.
  config.bypass_mouse_reporting_modifiers = "SHIFT"

  -- Hide pointer while typing to reduce visual noise in a keyboard-driven workflow.
  config.hide_mouse_cursor_when_typing = true

  config.mouse_bindings = {
    -- Single-click: cell selection
    { event = { Down = { streak = 1, button = "Left" } }, mods = "NONE", action = act.SelectTextAtMouseCursor("Cell") },
    { event = { Drag = { streak = 1, button = "Left" } }, mods = "NONE", action = act.ExtendSelectionToMouseCursor("Cell") },
    { event = { Up = { streak = 1, button = "Left" } }, mods = "NONE", action = act.CompleteSelection("PrimarySelection") },

    -- Double-click: word selection
    { event = { Down = { streak = 2, button = "Left" } }, mods = "NONE", action = act.SelectTextAtMouseCursor("Word") },
    { event = { Drag = { streak = 2, button = "Left" } }, mods = "NONE", action = act.ExtendSelectionToMouseCursor("Word") },
    { event = { Up = { streak = 2, button = "Left" } }, mods = "NONE", action = act.CompleteSelection("PrimarySelection") },

    -- Triple-click: line selection
    { event = { Down = { streak = 3, button = "Left" } }, mods = "NONE", action = act.SelectTextAtMouseCursor("Line") },
    { event = { Drag = { streak = 3, button = "Left" } }, mods = "NONE", action = act.ExtendSelectionToMouseCursor("Line") },
    { event = { Up = { streak = 3, button = "Left" } }, mods = "NONE", action = act.CompleteSelection("PrimarySelection") },

    -- Wheel scroll: keep natural scrolling; WezTerm computes delta per device.
    { event = { Down = { streak = 1, button = { WheelUp = 1 } } }, mods = "NONE", action = act.ScrollByCurrentEventWheelDelta },
    { event = { Down = { streak = 1, button = { WheelDown = 1 } } }, mods = "NONE", action = act.ScrollByCurrentEventWheelDelta },
  }
end

return M
