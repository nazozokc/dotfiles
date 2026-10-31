return {
	"mattn/emmet-vim",
	ft = { "html", "css", "scss", "javascriptreact", "typescriptreact" },
	init = function()
		-- Emmetのトリガーキー
		vim.g.user_emmet_leader_key = "<C-e>"

		-- 有効にするモード
		vim.g.user_emmet_mode = "inv"

		-- 全ファイルでの自動インストールを無効化
		vim.g.user_emmet_install_global = 0

		-- HTMLの言語設定
		vim.g.user_emmet_settings = {
			variables = {
				lang = "ja",
			},
		}
	end,
	config = function()
		-- 対応するFileTypeでEmmetを有効化
		vim.api.nvim_create_autocmd("FileType", {
			pattern = {
				"html",
				"css",
				"scss",
				"javascriptreact",
				"typescriptreact",
			},
			callback = function()
				vim.cmd("EmmetInstall")
			end,
		})
	end,
}
