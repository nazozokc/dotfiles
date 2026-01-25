return {
  "uga-rosa/ccc.nvim",
  cmd = { "CPicker" },
  config = function()
    require("ccc").setup({
      highlighter = {
        auto_enable = true,
      },
    })
  end,
}
