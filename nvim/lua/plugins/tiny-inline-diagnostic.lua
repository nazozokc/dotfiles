return {
	"rachartier/tiny-inline-diagnostic.nvim",
	event = "VeryLazy",
	priority = 1000,

	config = function()
		require("tiny-inline-diagnostic").setup({
			preset = "modern",
			throttle = 20,
			softwrap = 45,

			hi = {
				error = "DiagnosticError",
				warn = "DiagnosticWarn",
				info = "DiagnosticInfo",
				hint = "DiagnosticHint",
				arrow = "NonText",
				background = "CursorLine",
				mixing_color = "Normal",
			},

			options = {
				show_all_diags_on_cursorline = true,

				multilines = {
					enabled = true,
				},

				show_source = {
					enabled = true,
				},

				add_messages = {
					display_count = true,
				},
			},
		})

		vim.diagnostic.config({
			virtual_text = false,
		})
	end,
}
