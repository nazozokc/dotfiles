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
