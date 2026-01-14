return {
  "mhartington/formatter.nvim",
  event = "BufReadPost",
  config = function()
    local util = require("formatter.util")

    require("formatter").setup({
      logging = false,

      filetype = {
        lua = {
          require("formatter.filetypes.lua").stylua,
        },

        javascript = {
          require("formatter.filetypes.javascript").prettier,
        },

        typescript = {
          require("formatter.filetypes.typescript").prettier,
        },

        ["*"] = {
          require("formatter.filetypes.any").remove_trailing_whitespace,
        },
      },
    })

    -- 保存時フォーマット（明示的）
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = "*",
      command = "FormatWrite",
    })
  end,
}
