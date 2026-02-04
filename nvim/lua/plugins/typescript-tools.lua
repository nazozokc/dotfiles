return {
  "pmizio/typescript-tools.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "neovim/nvim-lspconfig",
  },
  ft = {
    "javascript", "javascriptreact",
    "typescript", "typescriptreact",
  },
  config = function()
    require("typescript-tools").setup {
      on_attach = function(client, bufnr)
        -- tsserver 自体の機能も削る
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false

        local function bufmap(mode, lhs, rhs)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true })
        end

        bufmap("n", "gd", vim.lsp.buf.definition)
        bufmap("n", "gr", "<cmd>Telescope lsp_references<CR>")
        bufmap("n", "<leader>oi", "<cmd>TSToolsOrganizeImports<CR>")
        bufmap("n", "<leader>ru", "<cmd>TSToolsRemoveUnused<CR>")
      end,

      settings = {
        -- ★ここが最重要
        separate_diagnostic_server = false, -- ← これONだと地獄
        publish_diagnostic_on = "insert_leave",

        -- 補完を軽くする
        complete_function_calls = false,
        include_completions_with_insert_text = false,

        -- 表示系は全部切る
        code_lens = "off",
        disable_member_code_lens = true,

        -- inlay hints 全無効
        tsserver_file_preferences = {
          includeInlayParameterNameHints = "none",
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = false,
          includeInlayVariableTypeHints = false,
          includeInlayPropertyDeclarationTypeHints = false,
          includeInlayFunctionLikeReturnTypeHints = false,
          includeInlayEnumMemberValueHints = false,
        },

        -- 不要なファイルを見ない（超重要）
        tsserver_format_options = {},
        tsserver_locale = "en",
      },
    }
  end
}
