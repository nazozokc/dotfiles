return {
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    config = function()
      require("notify").setup({ top_down = false, timeout = 2000, stages = "fade" })
      vim.notify = require("notify")
    end
  },
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {
      text = {
        spinner = "dots",
      },
      window = {
        blend = 0,
      },
    },
  },
}
