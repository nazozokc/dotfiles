return {
	"aznhe21/actions-preview.nvim",
	event = "LspAttach",
	keys = {
		{
			"<leader>ca",
			function()
				require("actions-preview").code_actions()
			end,
			desc = "Code Action (preview)",
		},
	},
	config = function()
		require("actions-preview").setup({
			telescope = {
				sorting_strategy = "ascending",
				layout_config = {
					prompt_position = "top",
				},
			},
		})
	end,
}
