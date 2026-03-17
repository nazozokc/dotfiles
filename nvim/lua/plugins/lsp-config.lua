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
				clang = "clangd",
				nixd = "nixd",
				jdtls = "jdtls",
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

			-- ===== HTML =====
			vim.lsp.config("html", {
				capabilities = capabilities,
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

			vim.lsp.config("clang", {
				capabilities = capabilities,
			})

			-- ===== Java =====
			vim.lsp.config("jdtls", {
				capabilities = capabilities,
				cmd = { "jdtls" },
				root_dir = vim.fs.root(0, { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }),
			})

			-- ===== 有効化 =====
			vim.lsp.enable(servers_to_enable)
		end,
	},
}
