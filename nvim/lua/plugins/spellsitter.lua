return {
  "lewis6991/spellsitter.nvim",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    require("spellsitter").setup()
  end,
}
