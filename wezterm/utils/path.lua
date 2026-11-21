-- Purpose: path helpers shared by tab titles and the status bar.

local M = {}

--- POSIX-style basename that also handles Windows separators and trailing /.
function M.basename(path)
	if not path then
		return ""
	end
	local normalized = path:gsub("\\", "/")
	return (normalized:gsub("/$", ""):match("([^/]+)$")) or normalized
end

--- Read the git branch for a pane's cwd without spawning `git`.
--- Handles a normal repo (.git/HEAD) as well as worktrees and submodules,
--- where .git is a file containing `gitdir: <path>`.
--- Returns nil for detached HEAD or when not inside a repository.
function M.git_branch(cwd_url)
	if not cwd_url or not cwd_url.file_path then
		return nil
	end

	local base = cwd_url.file_path:gsub("\\", "/")
	local dot_git = base .. "/.git"
	local head_path = dot_git .. "/HEAD"

	local f = io.open(head_path, "r")
	if not f then
		-- .git is a pointer file in worktrees and submodules.
		local pointer = io.open(dot_git, "r")
		if not pointer then
			return nil
		end
		local line = pointer:read("*l")
		pointer:close()
		local gitdir = line and line:match("^gitdir:%s*(.+)$")
		if not gitdir then
			return nil
		end
		gitdir = gitdir:gsub("\\", "/")
		-- Relative gitdir is resolved against the working directory.
		-- Absolute paths start with / (Unix) or X: (Windows).
		if gitdir:sub(1, 1) ~= "/" and not gitdir:match("^%a:") then
			gitdir = base .. "/" .. gitdir
		end
		head_path = gitdir .. "/HEAD"
		f = io.open(head_path, "r")
		if not f then
			return nil
		end
	end

	local content = f:read("*l")
	f:close()
	if not content then
		return nil
	end

	return content:match("ref: refs/heads/(.+)")
end

return M
