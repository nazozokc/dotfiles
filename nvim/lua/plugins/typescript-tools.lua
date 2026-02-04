return {
  "pmizio/typescript-tools.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "neovim/nvim-lspconfig", -- LSP共存はこれでOK
  },
  ft = {
    "javascript", "javascriptreact",
    "typescript", "typescriptreact",
  },
  config = function()
    require("typescript-tools").setup {
      on_attach = function(client, bufnr)
        -- キーマッピング例
        local function bufmap(mode, lhs, rhs) vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs,
            { silent = true, noremap = true }) end
        bufmap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
        bufmap("n", "gr", "<cmd>Telescope lsp_references<CR>")
        bufmap("n", "<leader>oi", "<cmd>TSToolsOrganizeImports<CR>") -- import 整理
        bufmap("n", "<leader>ru", "<cmd>TSToolsRemoveUnused<CR>")    -- 未使用削除
      end,
      settings = {
        -- これで普通に補完/診断/コードアクションが快適
        separate_diagnostic_server = true,
        publish_diagnostic_on = "insert_leave",
        tsserver_locale = "en",
        complete_function_calls = true,
        include_completions_with_insert_text = true,
        code_lens = "off",
        disable_member_code_lens = true,
      },
    }
  end
}
