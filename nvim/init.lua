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

-- lazy.nvim は install/update の最後に必ず lockfile を書き込むので、
-- 書き込み可能なパスしか渡せない。Nix 管理の symlink
-- (~/.config/nvim/lazy-lock.json) の終点は nix store 上の read-only な
-- スナップショット (dotfilesDir = self.outPath) なので、そこへは渡せない。
-- `nix run .#switch` を再実行しても解決しない (nix/README.md 参照)。
--
-- よって lockfile の実体は state 配下に置き、リポジトリの lazy-lock.json は
-- 「種 (seed)」として state 側が無いときだけコピーする。
-- :Lazy update で得たピンをリポジトリへ戻すときは:
--   cp ~/.local/state/nvim/lazy/lazy-lock.json nvim/lazy-lock.json
local uv = vim.uv or vim.loop
local lockfile = vim.fn.stdpath("state") .. "/lazy/lazy-lock.json"
local seedfile = vim.fn.stdpath("config") .. "/lazy-lock.json"

vim.fn.mkdir(vim.fn.fnamemodify(lockfile, ":h"), "p")

-- 既に書込可能なら state のピンを引き継ぐ。無い / read-only のときだけ
-- 種から作り直す。writefile なので 644 になる。
--
-- 注意: Neovim の filewritable() は Vim の 0/1/2 仕様と違う。
-- 「書込可能なら 1、それ以外 (無い / read-only) は 0」。
if vim.fn.filewritable(lockfile) == 0 and vim.fn.filereadable(seedfile) == 1 then
	uv.fs_unlink(lockfile)
	vim.fn.writefile(vim.fn.readfile(seedfile), lockfile)
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
