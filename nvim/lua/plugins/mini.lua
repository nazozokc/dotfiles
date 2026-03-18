return {
	-- 1. mini.ai（テキストオブジェクト、編集系なのでほぼすぐロード）
	{
		"echasnovski/mini.ai",
		version = false,
		event = "VeryLazy", -- 起動直後でなく、Lazyロード
		config = function()
			require("mini.ai").setup({ mappings = { around = "a", inside = "i" } })
		end,
	},

	-- 2. mini.surround（aiに依存するのでaiと同じタイミング）
	{
		"echasnovski/mini.surround",
		version = false,
		event = "VeryLazy",
		config = function()
			require("mini.surround").setup({
				mappings = { add = "sa", delete = "sd", replace = "sr", update_n_lines = "sn" },
			})
		end,
	},

	-- 3. mini.comment（コメント系は編集時にロード）
	{
		"echasnovski/mini.comment",
		version = false,
		event = "BufReadPre", -- バッファを開く直前に読み込む
		config = function()
			require("mini.comment").setup({ options = { ignore_blank_line = true, start_of_line = false } })
		end,
	},

	-- 4. mini.indentscope（見た目系、表示時に読み込み）
	{
		"echasnovski/mini.indentscope",
		version = false,
		event = "BufReadPost", -- バッファ読み込み後に描画
		config = function()
			require("mini.indentscope").setup({
				draw = {
					delay = 100,
					animation = function()
						return 0
					end,
				},
			})
		end,
	},

	-- 5. mini.jump（移動系、ノーマルモード入ったらロード）
	{
		"echasnovski/mini.jump",
		version = false,
		event = "CursorMoved", -- 最初のカーソル移動でロード
		config = function()
			require("mini.jump").setup({ mappings = { repeat_forward = ";", repeat_backward = "," } })
		end,
	},

	{
		"nvim-mini/mini.diff",
		event = "BufReadPre",
		config = function()
			require("mini.diff").setup({
				-- 差分の基準
				source = require("mini.diff").gen_source.git(),

				-- 表示設定
				view = {
					style = "number",
				},

				-- 差分更新の遅延(ms)
				delay = {
					text_change = 200,
				},

				-- マッピング
				mappings = {
					apply = "gh", -- 変更を適用
					reset = "gH", -- 元に戻す
					textobject = "gh", -- hunk選択
					goto_first = "[H",
					goto_prev = "[h",
					goto_next = "]h",
					goto_last = "]H",
				},

				-- overlay設定
				options = {
					wrap_goto = true,
				},
			})

			-- overlayトグル（これ重要）
			vim.keymap.set("n", "<leader>do", function()
				require("mini.diff").toggle_overlay()
			end, { desc = "Toggle diff overlay" })
		end,
	},
}
