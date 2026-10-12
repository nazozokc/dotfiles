return {
	"zeioth/garbage-day.nvim",
	event = "LspAttach",
	dependencies = "neovim/nvim-lspconfig",
	config = function()
		require("garbage-day").setup({
			aggressive_mode = false,
			excluded_lsp_clients = {
				"eslint",
				-- TypeScript LSP は停止すると復帰しない (start_lsp が不安定) ため除外する。
				-- TS7 内蔵 LSP の現行クライアント名は "tsgo"。
				-- nvim-lspconfig 3.0 で "tsc" へ改名予定、旧名 "tsserver" も念のため残す。
				"tsgo",
				"tsc",
				"tsserver",
			},
		})
	end,
}
