return {
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      ------------------------------------------------------------------
      -- TypeScript / ts_ls
      ------------------------------------------------------------------
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
        on_attach = function(client, bufnr)
          client.server_capabilities.documentFormattingProvider = false
          local opts = { buffer = bufnr }
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        end,
      })

      ------------------------------------------------------------------
      -- Lua
      ------------------------------------------------------------------
      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
          },
        },
        on_attach = function(client, bufnr)
          local opts = { buffer = bufnr }
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        end,
      })

      ------------------------------------------------------------------
      -- HTML
      ------------------------------------------------------------------
      vim.lsp.config("html", {
        capabilities = capabilities,
      })

      ------------------------------------------------------------------
      -- Ruby / solargraph
      ------------------------------------------------------------------
      vim.lsp.config("solargraph", {
        capabilities = capabilities,
      })
    end,
  },
}
