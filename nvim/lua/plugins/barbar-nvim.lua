return {
	"romgrk/barbar.nvim",
	event = "BufReadPre",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		"lewis6991/gitsigns.nvim",
	},
	init = function()
		vim.g.barbar_auto_setup = false
		vim.o.mouse = "a"
	end,
	opts = {
		animation = false,
		clickable = true,
		auto_hide = false, -- ← 安定重視
		focus_on_close = "left",
		sidebar_filetypes = { NvimTree = true },
		icons = {
			filetype = { enabled = true },
			button = "✕",
			modified = { button = "●" },
			pinned = { button = "📌", filename = true },
			separator = { left = "▎", right = "" },
		},
		maximum_padding = 1,
		minimum_padding = 1,
		maximum_length = 30,
		semantic_letters = true,
	},
	config = function(_, opts)
		require("barbar").setup(opts)
		local map = vim.keymap.set
		local o = { silent = true }

		map("n", "bn", "<Cmd>BufferNext<CR>", o)
		map("n", "bb", "<Cmd>BufferPrevious<CR>", o)
		map("n", "bt", "<Cmd>enew<CR>", o)
		map("n", "bw", "<Cmd>BufferClose<CR>", o)
		map("n", "bp", "<Cmd>BufferPick<CR>", o)
	end,
}
