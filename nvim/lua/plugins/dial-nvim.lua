return {
	"monaqa/dial.nvim",
	event = "VeryLazy",
	keys = { "<C-a>", "<C-x>" },
	config = function()
		local augend = require("dial.augend")

		local size = augend.constant.new({
			elements = { "small", "medium", "large" },
			word = true,
			cyclic = true,
		})
		local declaration = augend.constant.new({
			elements = { "let", "const", "var" },
			word = true,
			cyclic = true,
		})

		require("dial.config").augends:register_group({
			default = {
				augend.integer.alias.decimal,
				augend.constant.alias.bool,
				size,
				declaration,
			},
		})
	end,
}
