-- =============================
-- 高速化ガチ設定
-- =============================

vim.lsp.handlers["$/progress"] = function() end
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smartindent = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"

vim.opt.cursorline = false
vim.opt.colorcolumn = ""
vim.opt.laststatus = 3

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true

vim.opt.lazyredraw = false
vim.opt.ttyfast = true

vim.opt.pumheight = 10
vim.opt.pumblend = 0
vim.opt.winblend = 0

vim.opt.updatetime = 200
vim.opt.timeoutlen = 300

vim.opt.ruler = false
vim.opt.showmode = false
vim.opt.showcmd = false
vim.opt.cmdheight = 1
vim.opt.shortmess:append("c")

vim.g.mapleader = " "

