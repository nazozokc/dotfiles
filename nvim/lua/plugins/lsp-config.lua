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
    opts = {
      auto_install = true,
    },
  },

  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      local capabilities =
          require("cmp_nvim_lsp").default_capabilities()

      -- ===== 共通設定 =====
      local function on_attach(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local bufnr = args.buf

        -- tsserverはsemanticTokensが激重なので無効化
        if client and client.name == "ts_ls" then
          client.server_capabilities.semanticTokensProvider = nil
        end

        local opts = { buffer = bufnr }
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "<leader>gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = on_attach,
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

      -- 有効化
      vim.lsp.enable({
        "html",
        "lua_ls",
        "solargraph",
      })
    end,
  },
}
