return {
	"nvimdev/template.nvim",
	cmd = { "Template", "TemplateProject" },
	keys = {
		{ "<Leader>T", desc = "Template: insert template" },
	},
	config = function()
		require("template").setup({
			temp_dir = vim.fn.stdpath("config") .. "/template",
			author = "nazozokc",
			email = "nazozokc@gmail.com",

			variables = {
				["_year_"] = function()
					return os.date("%Y")
				end,
				["_date_"] = function()
					return os.date("%Y-%m-%d")
				end,
			},
		})

		vim.keymap.set("n", "<Leader>T", function()
			vim.fn.feedkeys(":Template ")
		end, { desc = "Template: insert template" })
	end,
}
