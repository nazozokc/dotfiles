return {
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      local capabilities =
          require("cmp_nvim_lsp").default_capabilities()

      -- TypeScript（軽量化）
      vim.lsp.config("ts_ls", {
        capabilities = capabilities,
        single_file_support = false,

        init_options = {
          hostInfo = "neovim",
          watchOptions = {
            ignoredFiles = {
              "**/node_modules/**",
              "**/.git/**",
              "**/dist/**",
              "**/build/**",
            },
          },
        },

        on_attach = function(client)
          client.server_capabilities.documentFormattingProvider = false
        end,
      })

      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
          },
        },
      })

      vim.lsp.config("html", {
        capabilities = capabilities,
      })

      vim.lsp.config("solargraph", {
        capabilities = capabilities,
      })

      -- LSP 有効化（これが必須）
vim.lsp.enable("ts_ls")
vim.lsp.enable("lua_ls")
vim.lsp.enable("html")
vim.lsp.enable("solargraph")


      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local opts = { buffer = ev.buf }
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        end,
      })
    end,
  },
}
