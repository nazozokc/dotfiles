-- Purpose: tab bar behavior + title formatting (status visibility without visual noise).
-- Shows current directory and Git branch when inside a repository.

local wezterm = require("wezterm")

local M = {}

local function basename(path)
	-- Handle both Unix (/) and Windows (\) path separators.
	local norm = path:gsub("\\", "/")
	return (norm:gsub("/$", ""):match("([^/]+)$")) or norm
end

--- Look up a Nerd Font icon for the running process in a pane.
--- Falls back to a terminal icon; detects SSH via pane title.
local function get_process_icon(process_name, pane_title)
	local name

	if process_name then
		name = basename(process_name):lower()
		name = name:gsub("%.exe$", "") -- Windows .exe suffix
	end

	-- SSH detection: no process path but title contains user@host
	if not name and pane_title then
		if pane_title:find("@") then
			name = "ssh"
		end
	end

	local icon_map = {
		nvim = wezterm.nerdfonts.linux_neovim,
		vim = wezterm.nerdfonts.dev_vim,
		ssh = wezterm.nerdfonts.md_lan,
		docker = wezterm.nerdfonts.md_docker,
		["docker-compose"] = wezterm.nerdfonts.md_docker,
		lazygit = wezterm.nerdfonts.dev_git_branch,
		git = wezterm.nerdfonts.dev_git_branch,
		btop = wezterm.nerdfonts.md_chart_donut,
		htop = wezterm.nerdfonts.md_chart_donut,
		python = wezterm.nerdfonts.dev_python,
		python3 = wezterm.nerdfonts.dev_python,
		node = wezterm.nerdfonts.dev_nodejs,
		npm = wezterm.nerdfonts.dev_nodejs,
		yarn = wezterm.nerdfonts.dev_nodejs,
		fish = wezterm.nerdfonts.md_fish,
		zsh = wezterm.nerdfonts.md_shell,
		bash = wezterm.nerdfonts.md_bash,
		top = wezterm.nerdfonts.md_chart_donut,
		tmux = wezterm.nerdfonts.md_application,
	}

	if name and icon_map[name] then
		return icon_map[name]
	end
	return wezterm.nerdfonts.dev_terminal
end

--- Read Git branch from .git/HEAD in the pane's working directory.
--- This is faster than spawning `git` and works on all platforms.
local function get_git_branch(cwd_url)
	if not cwd_url or not cwd_url.file_path then
		return nil
	end

	local git_dir = cwd_url.file_path:gsub("\\", "/") .. "/.git/HEAD"
	local f = io.open(git_dir, "r")
	if not f then
		return nil
	end

	local content = f:read("*l")
	f:close()
	if not content then
		return nil
	end

	-- "ref: refs/heads/main" → "main"
	return content:match("ref: refs/heads/(.+)")
end

local function pane_cwd_basename(pane)
	-- pane:get_current_working_dir() returns a URL object or nil
	local cwd_url = pane:get_current_working_dir()
	if cwd_url and cwd_url.file_path then
		return basename(cwd_url.file_path), cwd_url
	end
	-- Fallback: try pane title or current directory env
	local title = pane:get_title() or ""
	if title ~= "" then
		return title, nil
	end
	return "?", nil
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local pane = tab.active_pane
	local dir_name, cwd_url = pane_cwd_basename(pane)

	-- Build title parts
	local parts = {}

	-- Process icon (cross-platform; nil-safe)
	local icon = get_process_icon(pane.foreground_process_name, pane.title)
	parts[#parts + 1] = icon
	parts[#parts + 1] = " "

	local git_branch = get_git_branch(cwd_url)
	if git_branch then
		parts[#parts + 1] = wezterm.nerdfonts.dev_git_branch
		parts[#parts + 1] = " "
		parts[#parts + 1] = git_branch
		parts[#parts + 1] = "  "
	end
	parts[#parts + 1] = dir_name
	local title = table.concat(parts)

	local bg = tab.is_active and "#2D4F67" or "#181616"
	local fg = tab.is_active and "#C8C093" or "#c5c9c5"

	return {
		{ Background = { Color = bg } },
		{ Foreground = { Color = fg } },
		{ Text = " " .. wezterm.truncate_right(title, max_width - 2) .. " " },
	}
end)

function M.apply(config)
	-- Tabs are useful for long-running shells; hide bar when it adds no information.
	config.enable_tab_bar = true
	config.hide_tab_bar_if_only_one_tab = true

	-- Fancy tab bar spends vertical space on decorations; we keep it compact.
	config.use_fancy_tab_bar = false
	config.show_tab_index_in_tab_bar = false

	-- Wider max width to accommodate " branch-name  dirname" format.
	config.tab_max_width = 35
end

return M
