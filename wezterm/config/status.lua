-- Purpose: status bar (workspace, mode, git, hostname, CPU, GPU, time) + cursor color sync.
-- Cross-platform:
--   - CPU: Linux = /proc/stat (no spawn), macOS = ps, Windows = powershell
--   - GPU: nvidia-smi on any platform (gracefully skips if unavailable)
--   - All other APIs (wezterm.nerdfonts, wezterm.format, OSC 12) are native.

local wezterm = require("wezterm")
local platform = require("utils.platform")

local M = {}

-- ──────────────────────────────────────────────
-- Utilities
-- ──────────────────────────────────────────────

--- Spawn a child process and return trimmed stdout, or nil on failure.
local function run_cmd(args)
	local success, stdout = wezterm.run_child_process(args)
	if success and stdout then
		return stdout:gsub("^%s+", ""):gsub("%s+$", "")
	end
	return nil
end

--- Equivalent to POSIX basename(3); handles \ and / separators.
local function basename(path)
	if not path then
		return nil
	end
	local norm = path:gsub("\\", "/")
	return (norm:gsub("/$", ""):match("([^/]+)$")) or norm
end

--- Read git branch from .git/HEAD in the given cwd file-path.
local function get_git_branch(cwd_url)
	if not cwd_url or not cwd_url.file_path then
		return nil
	end

	local git_head = cwd_url.file_path:gsub("\\", "/") .. "/.git/HEAD"
	local f = io.open(git_head, "r")
	if not f then
		return nil
	end

	local content = f:read("*l")
	f:close()
	if not content then
		return nil
	end

	return content:match("ref: refs/heads/(.+)")
end

-- ──────────────────────────────────────────────
-- CPU usage (platform-specific, cached)
-- ──────────────────────────────────────────────

-- Linux delta state (persists between calls)
local cpu_delta = { idle_prev = 0, total_prev = 0, ready = false }
-- Shared cached result for all platforms
local cpu_cache = { value = nil, time = 0 }

local function fetch_cpu_linux()
	local f = io.open("/proc/stat", "r")
	if not f then
		return nil
	end

	local line = f:read("*l")
	f:close()
	if not line then
		return nil
	end

	local _, _, user, nice, sys, idle, iowait = line:match("^cpu%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)")
	if not user then
		return nil
	end

	local idle_ticks = tonumber(idle) + tonumber(iowait)
	local total_ticks = tonumber(user) + tonumber(nice) + tonumber(sys) + tonumber(idle) + tonumber(iowait)

	if not cpu_delta.ready then
		cpu_delta.idle_prev = idle_ticks
		cpu_delta.total_prev = total_ticks
		cpu_delta.ready = true
		return nil
	end

	local delta_idle = idle_ticks - cpu_delta.idle_prev
	local delta_total = total_ticks - cpu_delta.total_prev

	cpu_delta.idle_prev = idle_ticks
	cpu_delta.total_prev = total_ticks

	if delta_total == 0 then
		return 0
	end
	return math.floor((1 - delta_idle / delta_total) * 100 + 0.5)
end

local function fetch_cpu_macos()
	local result = run_cmd({ "bash", "-c", "ps -A -o %cpu | awk '{s+=$1} END {printf \"%d\\n\", int(s)}'" })
	if result then
		return tonumber(result)
	end
	return nil
end

local function fetch_cpu_windows()
	local result = run_cmd({
		"powershell",
		"-NoProfile",
		"-Command",
		"(Get-Counter '\\Processor(_Total)\\% Processor Time').CounterSamples.CookedValue",
	})
	if result then
		return tonumber(result)
	end
	return nil
end

--- Fetch current CPU usage percentage (0-100) or nil.
local function fetch_cpu()
	if platform.is_linux() then
		return fetch_cpu_linux()
	elseif platform.is_macos() then
		return fetch_cpu_macos()
	elseif platform.is_windows() then
		return fetch_cpu_windows()
	end
	return nil
end

-- ──────────────────────────────────────────────
-- GPU usage (nvidia-smi, cached, cross-platform)
-- ──────────────────────────────────────────────
local gpu_cache = { value = nil, time = 0 }
local gpu_checked = false -- true once we confirm nvidia-smi is absent

local function fetch_gpu()
	if gpu_checked then
		return nil
	end

	local result = run_cmd({ "nvidia-smi", "--query-gpu=utilization.gpu", "--format=csv,noheader" })
	if result then
		local pct = result:match("(%d+)")
		return pct and tonumber(pct) or nil
	end

	gpu_checked = true -- nvidia-smi not available; skip future attempts
	return nil
end

-- ──────────────────────────────────────────────
-- Mode detection
-- ──────────────────────────────────────────────

local function get_mode(window)
	local key_table = window:get_key_table_name()
	if key_table == "copy_mode" then
		return "COPY", "#ffd700"
	end
	return "NORMAL", "#80EBDF"
end

-- ──────────────────────────────────────────────
-- Status bar update
-- ──────────────────────────────────────────────

wezterm.on("update-status", function(window, pane)
	local now = os.time()
	local mode, mode_color = get_mode(window)
	local workspace = window:active_workspace()
	local hostname = wezterm.hostname()
	local time_str = os.date("%H:%M")

	-- ── Git branch (check every call; io.open is cheap) ──
	local cwd_url = pane:get_current_working_dir()
	local git_branch = get_git_branch(cwd_url)

	-- ── CPU (refresh more often on Linux where it's free) ──
	local cpu_interval = platform.is_linux() and 1 or 5
	if now - cpu_cache.time >= cpu_interval then
		cpu_cache.value = fetch_cpu()
		cpu_cache.time = now
	end

	-- ── GPU (refresh every 5s) ──
	if now - gpu_cache.time >= 5 then
		gpu_cache.value = fetch_gpu()
		gpu_cache.time = now
	end

	-- ── Left status: workspace + mode + git ──
	local left_items = {
		{ Foreground = { Color = mode_color } },
		{ Text = " " .. workspace },
		{ Foreground = { Color = "#c5c9c5" } },
		{ Text = " [" .. mode .. "]" },
	}

	if git_branch then
		left_items[#left_items + 1] = { Foreground = { Color = "#8A9A7B" } }
		left_items[#left_items + 1] = { Text = "  " .. wezterm.nerdfonts.dev_git_branch .. " " .. git_branch }
	end

	left_items[#left_items + 1] = { Text = " " }
	window:set_left_status(wezterm.format(left_items))

	-- ── Right status: hostname | cpu | gpu | time ──
	local right_items = {}

	-- hostname
	right_items[#right_items + 1] = { Foreground = { Color = "#8BA4B0" } }
	right_items[#right_items + 1] = { Text = wezterm.nerdfonts.md_server .. " " .. hostname }

	-- cpu
	if cpu_cache.value ~= nil then
		right_items[#right_items + 1] = { Foreground = { Color = "#8A9A7B" } }
		right_items[#right_items + 1] =
			{ Text = "  " .. wezterm.nerdfonts.md_cpu_64_bit .. " " .. cpu_cache.value .. "%" }
	end

	-- gpu
	if gpu_cache.value ~= nil then
		right_items[#right_items + 1] = { Foreground = { Color = "#A292A3" } }
		right_items[#right_items + 1] = { Text = "  " .. wezterm.nerdfonts.md_gpu .. " " .. gpu_cache.value .. "%" }
	end

	-- time
	right_items[#right_items + 1] = { Foreground = { Color = "#C4B28A" } }
	right_items[#right_items + 1] = { Text = "  " .. wezterm.nerdfonts.fa_clock_o .. " " .. time_str .. " " }

	window:set_right_status(wezterm.format(right_items))

	-- ── Cursor colour follows mode (OSC 12) ──
	pane:inject_output("\x1b]12;" .. mode_color .. "\x1b\\")
end)

function M.apply(config)
	-- How often update-status fires (milliseconds)
	config.status_update_interval = 1000
end

return M
