return {
	"rachartier/tiny-glimmer.nvim",
	event = "VeryLazy",
	config = function()
		require("tiny-glimmer").setup({
			enabled = true,
			disable_warnings = true,
			autoreload = true,

			-- CPU食いすぎ防止
			refresh_interval_ms = 16,

			-- surroundとか複数編集対策
			text_change_batch_timeout_ms = 80,

			overwrite = {
				auto_map = true,

				yank = {
					enabled = true,
					default_animation = "fade",
				},

				search = {
					enabled = false,
				},

				paste = {
					enabled = true,
					default_animation = "left_to_right",
					paste_mapping = "p",
					Paste_mapping = "P",
				},

				undo = {
					enabled = false,
				},

				redo = {
					enabled = false,
				},
			},

			support = {
				substitute = {
					enabled = true,
					default_animation = "fade",
				},
			},

			presets = {
				pulsar = {
					enabled = false,
				},
			},

			transparency_color = nil,

			animations = {
				fade = {
					max_duration = 250,
					min_duration = 180,
					easing = "outQuad",
					chars_for_max_duration = 12,

					-- Visualだとテーマ依存強すぎる
					from_color = "IncSearch",
					to_color = "Normal",

					font_style = {
						italic = false,
						bold = false,
					},
				},

				left_to_right = {
					max_duration = 220,
					min_duration = 180,
					min_progress = 0.8,
					chars_for_max_duration = 20,
					lingering_time = 20,

					from_color = "Substitute",
					to_color = "Normal",

					font_style = {},
				},

				reverse_fade = {
					max_duration = 220,
					min_duration = 180,
					easing = "outQuad",
					chars_for_max_duration = 12,

					from_color = "DiffAdd",
					to_color = "Normal",

					font_style = {},
				},

				pulse = {
					enabled = false,
				},

				rainbow = {
					enabled = false,
				},

				bounce = {
					enabled = false,
				},
			},

			hijack_ft_disabled = {
				"alpha",
				"snacks_dashboard",
				"neo-tree",
				"lazy",
				"mason",
			},

			virt_text = {
				priority = 2048,
			},
		})
	end,
}
