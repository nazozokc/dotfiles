return {
	{
		"neovim/nvim-lspconfig",
		event = "BufReadPre",
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			local function is_executable(cmd)
				return vim.fn.executable(cmd) == 1
			end

			local server_cmds = {
				html = "vscode-html-language-server",
				lua_ls = "lua-language-server",
				solargraph = "solargraph",
				efm = "efm-langserver",
				clangd = "clangd",
				nixd = "nixd",
				jdtls = "jdtls",
				sqls = "sqls",
				tailwindcss = "tailwindcss-language-server",
				tsgo = "tsgo",
			}

			local servers_to_enable = {}
			for server, cmd in pairs(server_cmds) do
				if is_executable(cmd) then
					table.insert(servers_to_enable, server)
				end
			end

			-- ===== 共通 on_attach =====
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local bufnr = args.buf

					local opts = { buffer = bufnr }
					vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
					vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, opts)
				end,
			})

			-- ===== HTML (JSX/TSX にもアタッチ) =====
			vim.lsp.config("html", {
				capabilities = capabilities,
				filetypes = { "html", "javascriptreact", "typescriptreact" },
				handlers = {
					["textDocument/publishDiagnostics"] = function(err, result, ctx)
						-- JSX/TSX の診断は tsserver が担当するため、
						-- html LSP の診断は html ファイルのみ通す（重複防止）
						if vim.bo[ctx.bufnr].filetype == "html" then
							vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx)
						end
					end,
				},
			})

			-- ===== Lua =====
			vim.lsp.config("lua_ls", {
				capabilities = capabilities,
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" },
						},
					},
				},
			})

			-- ===== Ruby =====
			vim.lsp.config("solargraph", {
				capabilities = capabilities,
			})

			vim.lsp.config("nixd", {
				capabilities = capabilities,
			})

			vim.lsp.config("efm", {
				capabilities = capabilities,
			})

			-- ===== C / C++ =====
			vim.lsp.config("clangd", {
				capabilities = capabilities,
				settings = {
					clangd = {
						-- compile_commands.json が無い環境でも診断が動くようにする
						fallbackFlags = { "-std=c++20" },
					},
				},
				init_options = {
					usePlaceholders = true,
				},
			})

			-- ===== Java =====
			vim.lsp.config("jdtls", {
				capabilities = capabilities,
				cmd = { "jdtls" },
				root_dir = vim.fs.root(0, { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }),
			})

			-- ===== SQL =====
			-- 接続設定はプロジェクトルートの .sqls/config.yml で行う
			vim.lsp.config("sqls", {
				capabilities = capabilities,
				settings = {
					sqls = {
						completion = {
							enabled = true,
						},
						diagnostics = {
							enable = true,
						},
					},
				},
			})

			-- ===== TypeScript / JavaScript =====
			-- TS7 (Go ネイティブ実装) 内蔵の LSP (`tsc --lsp --stdio`) を nvim-lspconfig の
			-- `tsgo` 設定で起動する。tsserver を廃した typescript-language-server /
			-- typescript-tools.nvim は tsserver.js (TS5) に依存するため使っていない。
			--
			-- 診断は pull diagnostics (textDocument/diagnostic)。Neovim 0.11+ は
			-- クライアントが対応していれば自動で pull を使う。
			vim.lsp.config("tsgo", {
				capabilities = capabilities,
				settings = {
					-- 設定は js/ts / typescript / javascript / editor セクションの
					-- うち js/ts が最優先。inlay hint と code lens は全部オフ。
					["js/ts"] = {
						inlayHints = {
							parameterNames = { enabled = "none" },
							parameterTypes = { enabled = false },
							variableTypes = { enabled = false },
							propertyDeclarationTypes = { enabled = false },
							functionLikeReturnTypes = { enabled = false },
							enumMemberValues = { enabled = false },
						},
						referencesCodeLens = { enabled = false },
						implementationsCodeLens = { enabled = false },
					},
				},
				on_attach = function(client, bufnr)
					-- 整形は conform (prettier) に任せる。capabilities 側で
					-- `textDocument.formatting = false` を送ると TS7 の LSP が
					-- object 前提で parse に失敗して initialize が失敗するので、
					-- server_capabilities 側で落とす
					client.server_capabilities.documentFormattingProvider = false
					client.server_capabilities.documentRangeFormattingProvider = false

					-- typescript-tools.nvim が提供していたコマンドを
					-- code action (source.*) に置き換える。
					-- apply = true で選択枠無し・diff 表示なしで即適用する
					local function bufmap(lhs, kind)
						vim.keymap.set("n", lhs, function()
							vim.lsp.buf.code_action({ context = { only = { kind } }, apply = true })
						end, { buffer = bufnr, silent = true })
					end

					bufmap("<leader>oi", "source.organizeImports")
					bufmap("<leader>ru", "source.removeUnusedImports")
				end,
			})

			-- ===== Tailwind CSS (tailwind.config 検出時のみ起動) =====
			vim.lsp.config("tailwindcss", {
				capabilities = capabilities,
				filetypes = {
					"typescript",
					"typescriptreact",
					"javascript",
					"javascriptreact",
					"css",
					"scss",
					"html",
				},
				root_dir = function(fname)
					return vim.fs.root(fname, {
						"tailwind.config.js",
						"tailwind.config.ts",
						"tailwind.config.cjs",
						"tailwind.config.mjs",
					})
				end,
				settings = {
					tailwindCSS = {
						includeLanguages = {
							typescriptreact = "html",
							javascriptreact = "html",
						},
					},
				},
			})

			-- ===== 有効化 =====
			vim.lsp.enable(servers_to_enable)
		end,
	},
}
