return {
	"akinsho/toggleterm.nvim",
	event = "VeryLazy",
	cmd = "Toggleterm",
	version = "*",
	keys = {
		{ "<leader>t", "<cmd>ToggleTerm<CR>", desc = "Toggle Terminal" },
	},
	config = function()
		require("toggleterm").setup({
			direction = "float",
			float_opts = {
				border = "rounded",
			},
		})
	end,
}
