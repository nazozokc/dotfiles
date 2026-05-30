vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.g.mapleader = " "
vim.o.background = "dark"

vim.opt.swapfile = false

vim.opt.modeline = false
vim.opt.modelines = 0

vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/site")

-- Navigate vim panes better
vim.keymap.set("n", "<c-k>", ":wincmd k<CR>")
vim.keymap.set("n", "<c-j>", ":wincmd j<CR>")
vim.keymap.set("n", "<c-h>", ":wincmd h<CR>")
vim.keymap.set("n", "<c-l>", ":wincmd l<CR>")

vim.keymap.set("n", "<leader>h", ":nohlsearch<CR>")
vim.wo.number = true
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"
vim.opt.wildignorecase = true

-- IME: Insert モードを抜けるときに英数入力に切り替え
local function detect_ime_off()
	if vim.fn.executable("fcitx5-remote") == 1 then
		return "fcitx5-remote -c"
	elseif vim.fn.executable("fcitx-remote") == 1 then
		return "fcitx-remote -c"
	elseif vim.fn.executable("ibus") == 1 then
		return "ibus engine xkb:us::eng"
	elseif vim.fn.has("mac") == 1 and vim.fn.executable("macism") == 1 then
		return "macism com.apple.keylayout.ABC"
	end
	return nil
end

local ime_off_cmd = detect_ime_off()
if ime_off_cmd then
	vim.api.nvim_create_autocmd("InsertLeave", {
		callback = function()
			vim.fn.system(ime_off_cmd)
		end,
	})
end
