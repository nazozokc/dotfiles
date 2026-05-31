return {
	"nemanjamalesija/ts-expand-hover.nvim",
	ft = { "typescript", "typescriptreact" },
	opts = {
		keymaps = {
			hover = "K", -- normal mode key to open hover float
			expand = "+", -- expand type one level (inside float)
			collapse = "-", -- collapse type one level (inside float)
			close = { "q", "<Esc>" }, -- close float and return to source
		},
		float = {
			border = "rounded", -- "rounded", "single", "double", "none"
			max_width = 80,
			max_height = 30,
		},
	},
}
