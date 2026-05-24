-- Purpose: launch menu entries for quick-starting common sessions.
-- Accessible via the command palette (Ctrl+Shift+P → "Launch").
-- Each entry appears as a selectable item; selecting it opens a new tab/pane.

local platform = require("utils.platform")

local M = {}

function M.apply(config)
	config.launch_menu = {
		{ label = "Fish", args = { "fish" } },
		{ label = "Zsh", args = { "zsh" } },
		{ label = "Bash", args = { "bash" } },
	}

	-- Guard: HOME/USERPROFILE might be nil on some Windows environments
	local home = os.getenv("HOME") or os.getenv("USERPROFILE")
	if home then
		table.insert(config.launch_menu, {
			label = "Dotfiles",
			cwd = home .. "/ghq/github.com/nazozokc/dotfiles",
		})
	end

	-- Platform-specific entries
	if platform.is_linux() then
		table.insert(config.launch_menu, { label = "Htop", args = { "htop" } })
		table.insert(config.launch_menu, { label = "Btop", args = { "btop" } })
	elseif platform.is_macos() then
		table.insert(config.launch_menu, { label = "Htop", args = { "htop" } })
	end
end

return M
