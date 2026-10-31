return {
	"glepnir/lspsaga.nvim",
	event = "LspAttach",
	keys = {
		{ "ga", "<cmd>Lspsaga code_action<CR>", desc = "Code Action" },
		{ "gd", "<cmd>Lspsaga goto_definition<CR>", desc = "Go to Definition" },
	},
	branch = "main",
	config = function()
		require("lspsaga").setup({})
	end,
}
