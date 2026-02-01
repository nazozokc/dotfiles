return {
  "rachartier/tiny-inline-diagnostic.nvim",
  config = function()
    require("tiny-inline-diagnostic").setup({
  signs = false,
  virtual_text = false,
  update_in_insert = false, -- ←超重要
})
vim.diagnostic.config({ virtual_text = true }) -- 内蔵のやつ OFF
  end,
}
