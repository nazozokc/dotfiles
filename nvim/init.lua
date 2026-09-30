-- =========================================================
-- Basic UI options
-- =========================================================
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.cursorcolumn = true
vim.api.nvim_set_hl(0, "CursorLine", {
	bg = "#404040",
})

vim.api.nvim_set_hl(0, "CursorColumn", {
	bg = "#4a4a4a",
})

-- Insert モード中は relative number を無効化
vim.api.nvim_create_autocmd("InsertEnter", {
	callback = function()
		vim.opt.relativenumber = false
	end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
	callback = function()
		vim.opt.relativenumber = true
	end,
})

-- =========================================================
-- Load configs
-- =========================================================
require("vim-options")

-- lazy.nvim bootstrap
--
-- Nix 管理環境 (nix run .#switch 済み) では LAZY_NIX_PLUGINS が
-- nix store の farm を指す。lazy.nvim 自身も pkgs.vimPlugins.lazy-nvim として
-- farm に入るので、git clone はしない。
--
-- LAZY_NIX_PLUGINS が無い環境 (Windows 側の apply.ps1 / 素の Neovim) では
-- 従来どおり自分で clone する。
local nixPlugins = os.getenv("LAZY_NIX_PLUGINS")
if nixPlugins == "" then
	nixPlugins = nil
end

local lazypath
if nixPlugins then
	lazypath = nixPlugins .. "/lazy.nvim"
else
	lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
	if not (vim.uv or vim.loop).fs_stat(lazypath) then
		vim.fn.system({
			"git",
			"clone",
			"--filter=blob:none",
			"https://github.com/folke/lazy.nvim.git",
			"--branch=stable", -- latest stable release
			lazypath,
		})
	end
end
vim.opt.rtp:prepend(lazypath)

-- lockfile は Nix (home-manager) 管理。out-of-store symlink により
-- ~/.config/nvim/lazy-lock.json はリポジトリの nvim/lazy-lock.json を指す。
-- lazy.nvim が直接書き込むので、install/update で得たピン留めは
-- リポジトリ側にそのまま残る（state へ複写して手動 cp で戻す運用は不要）。
--
-- ただし symlink 未適用（nix run .#switch 前）や Nix store 直参照だと
-- read-only になり E5113 (Permission denied) で落ちるので、その場合だけ
-- state 配下へ退避して起動できるようにしておく。
local uv = vim.uv or vim.loop
local lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json"
if vim.fn.filewritable(lockfile) == 0 then
	vim.notify(
		"lazy-lock.json が read-only です。`nix run .#switch` で Nix 管理の symlink を適用してください\n"
			.. "  暫定的に state 配下の lockfile を使います（ピン留めはリポジトリに反映されません）\n"
			.. "  "
			.. lockfile,
		vim.log.levels.WARN
	)
	local fallback = vim.fn.stdpath("state") .. "/lazy/lazy-lock.json"
	vim.fn.mkdir(vim.fn.fnamemodify(fallback, ":h"), "p")
	if vim.fn.filewritable(fallback) ~= 2 then
		-- 既存の 444 などは除去して作り直す。writefile なので 644 で作成される。
		uv.fs_unlink(fallback)
		vim.fn.writefile(vim.fn.readfile(vim.fn.stdpath("config") .. "/lazy-lock.json"), fallback)
	end
	lockfile = fallback
end

local lazyOpts = {
	lockfile = lockfile,
	rocks = {
		enabled = false,
	},
	git = {
		timeout = 600,
	},
}

if nixPlugins then
	-- プラグインの宣言は nvim/lua/plugins/*.lua に残したまま、
	-- 実体 (install 先) だけを nix store の farm へ差し替える。
	-- lazy.nvim は `dev` プラグインを local 扱いするため
	-- install/update/sync の対象外になる = バージョンは Nix だけが決める。
	--
	-- farm に無いプラグインは fallback で通常の root
	-- (stdpath("data")/lazy) へ落ちる。
	-- 現在は Nix 管理外の swagger-preview.nvim だけが这条路を使う。
	lazyOpts.dev = {
		-- 全プラグインを対象にする
		patterns = { "." },
		path = function(plugin)
			return nixPlugins .. "/" .. plugin.name
		end,
		-- farm に無いものは root へ落とす
		fallback = true,
	}
end

require("lazy").setup("plugins", lazyOpts)

-- =========================================================
-- Keymaps
-- =========================================================
local map = vim.keymap.set

-- ---------------------------------------------------------
-- UI / Toggle
-- ---------------------------------------------------------
map("n", "<leader>t", ":ToggleTerm<CR>", {})
map("n", "<leader>c", ":Oil ~/ghq/github.com/nazozokc/dotfiles/<CR>", {})
map("n", "<leader>so", ":SymbolsOutline<CR>")
map("n", "<F2>", ":Twilight<CR>", {})
map("n", "<leader>e", ":TroubleToggle<CR>")

-- ---------------------------------------------------------
-- LSP (Lspsaga / Actions)
-- ---------------------------------------------------------
map("n", "ga", "<cmd>Lspsaga code_action<CR>")
map("n", "gd", "<cmd>Lspsaga goto_definition<CR>")

map("n", "<leader>ca", function()
	require("actions-preview").code_actions()
end, { desc = "Code Action (preview)" })

-- ---------------------------------------------------------
-- Snacks.nvim (Picker / Zen)
-- ---------------------------------------------------------
map("n", "<leader><leader>", function()
	require("snacks.picker").files()
end, { desc = "Files" })

map("n", "<leader>g", function()
	require("snacks.picker").grep()
end, { desc = "Live Grep" })

map("n", "<leader>b", function()
	require("snacks.picker").buffers()
end, { desc = "Buffers" })

map("n", "<leader>r", function()
	require("snacks.picker").recent()
end, { desc = "Recent Files" })

map("n", "<leader>z", function()
	require("snacks").zen.toggle()
end, { desc = "Zen Mode" })
