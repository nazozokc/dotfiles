-- plugins/lualine.lua
return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons", "folke/trouble.nvim" },
	config = function()
		require("lualine").setup({
			options = {
				theme = "kanagawa",
				section_separators = { left = "", right = "" },
				component_separators = { left = "", right = "" },
				globalstatus = true,
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch" },
			},
		})
	end,
}
