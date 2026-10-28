return {
	{
		"uga-rosa/translate.nvim",
		cmd = { "Translate" },
		config = function()
			require("translate").setup({
				default = {
					command = "google",
					from = "auto",
					to = "ja",
				},
				keymaps = {
					i = "<C-s>",
					n = "<Leader>ts",
					v = "<Leader>ts",
				},
			})
		end,
	},
}
