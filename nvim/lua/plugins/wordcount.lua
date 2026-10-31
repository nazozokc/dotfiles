return {
	"nazozokc/wordcount.nvim",
	event = "BufReadPre",
	config = function()
		require("wordcount").setup({
			enabled = true,
			position = "bottom_right", -- top_left / top_right / bottom_left / bottom_right
			debounce_ms = 100,
			format = "Characters: %d",
			markdown = {
				include_frontmatter = false,
			},
		})
	end,
}
