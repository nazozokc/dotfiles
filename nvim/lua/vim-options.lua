-- =============================
-- 基本設定（高速化重視）
-- =============================

-- タブとインデント
vim.opt.expandtab = true       -- タブをスペースに
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smartindent = true     -- 自動インデント

-- ファイル操作系
vim.opt.swapfile = false       -- スワップファイル無効
vim.opt.backup = false         -- バックアップ無効
vim.opt.undofile = true        -- undo 履歴は有効
vim.opt.updatetime = 300       -- CursorHold の待機時間を短縮

-- 表示
vim.opt.number = true          -- 行番号
vim.opt.relativenumber = true  -- 相対行番号
vim.opt.cursorline = true      -- カーソル行をハイライト
vim.opt.wrap = false           -- 行折り返し無効
vim.opt.scrolloff = 8          -- 上下スクロール余白
vim.opt.signcolumn = "yes"     -- 常にサインカラム表示
vim.opt.colorcolumn = "80"     -- 目安の列

-- 検索
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true

-- リーダーキー
vim.g.mapleader = " "

-- =============================
-- キーマッピング（高速化重視）
-- =============================
local map = vim.keymap.set
local opts = { silent = true, noremap = true }

-- ウィンドウ移動
map('n', '<C-h>', '<C-w>h', opts)
map('n', '<C-j>', '<C-w>j', opts)
map('n', '<C-k>', '<C-w>k', opts)
map('n', '<C-l>', '<C-w>l', opts)

-- 検索ハイライト解除
map('n', '<leader>h', ':nohlsearch<CR>', opts)

-- タブ補完軽量
map('i', '<Tab>', 'v:lua.tab_complete()', { expr = true, noremap = true })
map('i', '<S-Tab>', 'v:lua.s_tab_complete()', { expr = true, noremap = true })

-- =============================
-- 軽量プラグイン管理（Lazy.nvim推奨）
-- =============================
-- 必要最低限のプラグインのみ
--   - nvim-lspconfig: LSP
--   - nvim-cmp + denippet: 補完 + スニペット
--   - telescope は省略（重いので必要ならあとから追加）
-- =============================
-- ここでは設定例だけ Lua で残す
-- require("lazy").setup({
--   { "neovim/nvim-lspconfig", lazy = false },
--   { "hrsh7th/nvim-cmp", dependencies = { "uga-rosa/denippet.vim", "uga-rosa/cmp-denippet" } },
-- })
vim.opt.lazyredraw = true

-- =============================
-- 高速化のため無効化
-- =============================
vim.opt.laststatus = 2          -- ステータスラインを固定
vim.opt.ruler = false
vim.opt.showmode = false
vim.opt.showcmd = false
vim.opt.cmdheight = 1           -- コマンドライン高さ最小化
vim.opt.shortmess:append("c")   -- メッセージ短縮

