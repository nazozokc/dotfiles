return {
	{
		"folke/noice.nvim",

		event = "UIEnter",

		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},

		opts = {
			-- =====================================================
			-- Cmdline
			-- =====================================================
			cmdline = {
				enabled = true,
				view = "cmdline_popup",

				format = {
					cmdline = {
						icon = ">>>",
						lang = "vim",
					},

					search_down = {
						icon = "🔍⌄",
						lang = "regex",
					},

					search_up = {
						icon = "🔍⌃",
						lang = "regex",
					},

					lua = {
						icon = "λ",
						lang = "lua",
					},
				},
			},

			-- =====================================================
			-- Messages
			-- =====================================================
			messages = {
				enabled = true,

				-- virtualtext は cursorline/cursorcolumn と
				-- redraw 競合しやすい
				view_search = false,
			},

			-- =====================================================
			-- Popupmenu
			-- =====================================================
			popupmenu = {
				enabled = true,
				backend = "nui",
			},

			-- =====================================================
			-- Notifications
			-- =====================================================
			notify = {
				enabled = false,
			},

			-- =====================================================
			-- LSP
			-- =====================================================
			lsp = {
				-- progress は redraw 汚しやすい
				progress = {
					enabled = false,
				},

				hover = {
					enabled = true,
				},

				-- lspsaga と競合するから切る
				signature = {
					enabled = false,
				},

				message = {
					enabled = true,
				},

				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},

			-- =====================================================
			-- Presets
			-- =====================================================
			presets = {
				bottom_search = true,
				command_palette = true,
				long_message_to_split = true,
			},
		},

		config = function(_, opts)
			require("noice").setup(opts)

			-- =================================================
			-- Transparent popup
			-- =================================================
			local function set_highlights()
				vim.api.nvim_set_hl(0, "NoicePopup", {
					bg = "NONE",
				})

				vim.api.nvim_set_hl(0, "NoicePopupBorder", {
					bg = "NONE",
				})

				-- CursorLine
				vim.api.nvim_set_hl(0, "CursorLine", {
					bg = "#3b3b50",
				})

				-- CursorColumn
				vim.api.nvim_set_hl(0, "CursorColumn", {
					bg = "#303045",
				})
			end

			set_highlights()

			vim.api.nvim_create_autocmd("ColorScheme", {
				callback = set_highlights,
			})

			-- redraw stabilization
			vim.schedule(function()
				vim.cmd("redraw")

				vim.opt.cursorline = true
				vim.opt.cursorcolumn = true
				vim.opt.cursorlineopt = "line,number"
			end)
		end,
	},
}
