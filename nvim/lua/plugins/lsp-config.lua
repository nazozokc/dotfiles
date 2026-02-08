return {
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities =
        require("cmp_nvim_lsp").default_capabilities()

      -- ===== 共通 on_attach =====
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          local bufnr = args.buf

          -- ts_ls は semanticTokens が重いので切る
          if client and client.name == "ts_ls" then
            client.server_capabilities.semanticTokensProvider = nil
          end

          local opts = { buffer = bufnr }
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        end,
      })

      -- ===== HTML =====
      lspconfig.html.setup({
        capabilities = capabilities,
      })

      -- ===== Lua =====
      lspconfig.lua_ls.setup({
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
      lspconfig.solargraph.setup({
        capabilities = capabilities,
      })

      -- ===== JavaScript / TypeScript =====
      lspconfig.ts_ls.setup({
        capabilities = capabilities,
        cmd = { "typescript-language-server", "--stdio" },
        filetypes = {
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact",
        },
        root_dir = lspconfig.util.root_pattern(
          "package.json",
          "tsconfig.json",
          ".git"
        ),
      })
    end,
  },
}

