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
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({})
    end
  },
  {
    "zbirenbaum/copilot-cmp",
    event = "VeryLazy",
    config = function()
      require("copilot_cmp").setup({})
    end
  },
}
