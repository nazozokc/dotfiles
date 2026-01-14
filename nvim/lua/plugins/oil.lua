return {
  "stevearc/oil.nvim",
  event = "VeryLazy",
  cmd = { "Oil" },
  config = function()
    local oil = require("oil")
    oil.setup()
    vim.keymap.set("n", "<leader>m", oil.toggle_float, {})
  end,
}
