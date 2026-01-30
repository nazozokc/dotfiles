return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    cmd = { "CopilotChat" },
    build = "make tiktoken", -- optional だけどできるなら
    opts = {},
  },
  {
    "zbirenbaum/copilot-cmp",
    event = "VeryLazy",
    dependencies = {
      "zbirenbaum/copilot.lua",
    },
    config = function()
      require("copilot_cmp").setup({})
    end,
  },
}
