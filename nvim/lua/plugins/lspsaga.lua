return {
 	"glepnir/lspsaga.nvim",
 	event = "LspAttach",
 	keys = {},
 	branch = "main",
 	config = function()
 		require("lspsaga").setup({})
 	end,
 }
