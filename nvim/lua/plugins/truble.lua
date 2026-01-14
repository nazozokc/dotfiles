return {
  "folke/trouble.nvim",
  event = "InsertEnter",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = { "Trouble", "TroubleToggle" },
  keys = {
    { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",              desc = "Toggle Diagnostics (Trouble)" },
    { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics" },
    { "<leader>cs", "<cmd>Trouble symbols toggle<cr>",                  desc = "Symbols (Trouble)" },
    { "<leader>cl", "<cmd>Trouble lsp toggle<cr>",                      desc = "LSP List" },
  },
  opts = {
    auto_close = false,
    auto_open = false,
    auto_preview = true,
    multiline = true,
    indent_guides = true,
    win = { position = "right", size = 40 },
    icons = { -- ←ここをテーブルで指定
      Error = "",
      Warning = "",
      Information = "",
      Hint = "",
    },
  },
  config = function(_, opts)
    local trouble = require("trouble")
    trouble.setup(opts)

    -- lualine 用ステータスラインシンボル
    local symbols = trouble.statusline({
      mode = "lsp_document_symbols",
      title = false,
      filter = { range = true },
      format = "{kind_icon}{symbol.name:Normal}",
      hl_group = "lualine_c_normal",
      icons = opts.icons,
    })

    -- もし lualine に直接組み込みたい場合は
    -- require("lualine").setup() 内の lualine_c に { symbols.get, cond = symbols.has } を入れる
  end,
}
