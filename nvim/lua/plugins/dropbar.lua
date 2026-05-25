return {
	"Bekaboo/dropbar.nvim",

	event = { "BufReadPre", "BufNewFile" },

	dependencies = {
		"nvim-tree/nvim-web-devicons",

		-- fuzzy find support
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
		},
	},

	config = function()
		local dropbar = require("dropbar")
		local api = require("dropbar.api")
		local sources = require("dropbar.sources")
		local utils = require("dropbar.utils")

		dropbar.setup({
			icons = {
				ui = {
					bar = {
						separator = "  ",
					},
				},
			},

			bar = {
				enable = function(_, win)
					local buf = vim.api.nvim_win_get_buf(win)

					local ft = vim.bo[buf].filetype
					local bt = vim.bo[buf].buftype

					-- 無効化したい場所
					local ignored = {
						"neo-tree",
						"NvimTree",
						"toggleterm",
						"Trouble",
						"dashboard",
						"alpha",
						"lazy",
						"mason",
						"notify",
						"snacks_dashboard",
					}

					if vim.tbl_contains(ignored, ft) then
						return false
					end

					if bt == "nofile" then
						return false
					end

					return vim.api.nvim_win_get_width(win) > 60
				end,

				sources = function(buf, _)
					local ft = vim.bo[buf].filetype
					local bt = vim.bo[buf].buftype

					-- terminal
					if bt == "terminal" then
						return {
							sources.terminal,
						}
					end

					-- markdown
					if ft == "markdown" then
						return {
							sources.path,
							sources.markdown,
						}
					end

					-- 普段用
					return {
						sources.path,

						utils.source.fallback({
							sources.lsp,
							sources.treesitter,
						}),
					}
				end,
			},

			menu = {
				win_configs = {
					border = "rounded",
				},
			},
		})

		-- =========
		-- keymaps
		-- =========

		vim.keymap.set("n", "<leader>;", api.pick, {
			desc = "Dropbar pick",
		})

		vim.keymap.set("n", "[;", api.goto_context_start, {
			desc = "Context start",
		})

		vim.keymap.set("n", "];", api.select_next_context, {
			desc = "Next context",
		})

		-- mouse hover support
		vim.opt.mousemoveevent = true
	end,
}
