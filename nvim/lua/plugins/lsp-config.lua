return {
  {
    "williamboman/mason.nvim",
    lazy = false,
    config = function()
      require("mason").setup()
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "ts_ls",
          "lua_ls",
          "html",
          "solargraph",
        },
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      local capabilities =
          require("cmp_nvim_lsp").default_capabilities()

      -- ts_ls（TypeScript / 軽量化）
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

        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = "none",
              includeInlayFunctionParameterTypeHints = false,
              includeInlayVariableTypeHints = false,
              includeInlayFunctionReturnTypeHints = false,
            },
          },
          javascript = {
            inlayHints = {
              includeInlayParameterNameHints = "none",
            },
          },
        },

        on_attach = function(client)
          client.server_capabilities.documentFormattingProvider = false
        end,
      })

      vim.lsp.config("solargraph", {
        capabilities = capabilities,
      })

      vim.lsp.config("html", {
        capabilities = capabilities,
      })

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

      -- LSP keymaps
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
