return {
	{
		-- rust-analyzer 統合 (rust-tools.nvim の後継)。
		-- filetype plugin のため lazy = false が推奨 (:h rustaceanvim)。
		"mrcjkb/rustaceanvim",
		-- バージョンは farm (nvim-plug-manage/flake.lock の rev) が固定する
		lazy = false,
		ft = { "rust" },
		config = function()
			-- nvim wrapper の PATH では home-manager の rustup shim が先に解決され、
			-- rust-analyzer は shim → profile → shim の無限再帰で落ちる。
			-- nix store の実体を extraWrapperArgs の RUST_ANALYZER で指す。
			local rust_analyzer = os.getenv("RUST_ANALYZER") or "rust-analyzer"

			vim.g.rustaceanvim = {
				server = {
					cmd = { rust_analyzer },
					default_settings = {
						["rust-analyzer"] = {
							cargo = { features = "all" },
							procMacro = { enable = true },
							checkOnSave = true,
							check = { command = "clippy" },
						},
					},
					on_attach = function(client, bufnr)
						local map = function(lhs, rhs, desc)
							vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
						end

						map("K", "<Cmd>RustLsp hover actions<CR>", "Hover Actions")
						map("<leader>rr", "<Cmd>RustLsp runnables<CR>", "Rust Runnables")
						map("<leader>rd", "<Cmd>RustLsp debuggables<CR>", "Rust Debuggables")
						map("<leader>rm", "<Cmd>RustLsp expandMacro<CR>", "Expand Macro")

						-- Inlay Hints トグル (全自動表示 + 手動トグル)
						local toggle_hints = function()
							vim.lsp.inlay_hint.enable(
								not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }),
								{ bufnr = bufnr }
							)
						end
						map("<leader>th", toggle_hints, "Toggle Inlay Hints")
						if client.server_capabilities.inlayHintProvider then
							vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
						end
					end,
				},
				dap = (function()
					-- codelldb は nix store から wrapper 経由の CODELLDB / LIBLLDB で受ける。
					-- 無い環境 (Windows の apply.ps1 など) ではデバッグ設定を作らない。
					local codelldb = os.getenv("CODELLDB")
					local liblldb = os.getenv("LIBLLDB")
					if
						not codelldb
						or codelldb == ""
						or not liblldb
						or liblldb == ""
						or vim.uv.fs_stat(codelldb) == nil
						or vim.uv.fs_stat(liblldb) == nil
					then
						return nil
					end
					return {
						adapter = require("rustaceanvim.config").get_codelldb_adapter(codelldb, liblldb),
					}
				end)(),
			}
		end,
	},
}
