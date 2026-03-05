-- ~/.config/nvim/lua/plugins/indent-blankline.lua
return {
	"lukas-reineke/indent-blankline.nvim",
	event = "VimEnter",
	main = "ibl",
	opts = {
		indent = {
			char = "│",
		},
		scope = {
			enabled = false,
		},
	},
}
