return {
  "glepnir/lspsaga.nvim",
event = "LspAttach",
  branch = "main",
  config = function()
    require("lspsaga").setup({})
  end,
}
