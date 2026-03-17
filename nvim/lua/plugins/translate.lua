return {
	{
		"uga-rosa/translate.nvim",
		cmd = { "Translate" },
		config = function()
			require("translate").setup({
				default = {
					command = "google", -- 使用する翻訳サービス
					from = "auto", -- 原文言語
					to = "ja", -- 翻訳先言語
				},
<<<<<<< HEAD
			keymaps = {
				i = "<C-s>", -- 挿入モードで翻訳
				n = "<Leader>T", -- ノーマルモードで翻訳
				v = "<Leader>T", -- ビジュアルモードで翻訳
			},
=======
				keymaps = {
					i = "<C-s>", -- 挿入モードで翻訳
					n = "<Leader>T", -- ノーマルモードで翻訳
					v = "<Leader>T", -- ビジュアルモードで翻訳
				},
>>>>>>> main
			})
		end,
	},
}
