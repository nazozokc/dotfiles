-- =========================
-- Debug (JS / TS)
-- =========================
return {
  {
    "mfussenegger/nvim-dap",
  },

  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    config = function()
      require("dapui").setup()
    end,
  },

  {
    -- ★ build を消すのが超重要
    "microsoft/vscode-js-debug",
    lazy = true,
  },

  {
    "mxsdev/nvim-dap-vscode-js",
    dependencies = {
      "mfussenegger/nvim-dap",
      "microsoft/vscode-js-debug",
    },
    config = function()
      require("dap-vscode-js").setup({
        adapters = {
          "pwa-node",
          "pwa-chrome",
          "pwa-msedge",
        },
      })
    end,
  },

  {
    "theHamsta/nvim-dap-virtual-text",
    opts = {
      enabled = true,
      enabled_commands = true,
      highlight_changed_variables = true,
      highlight_new_as_changed = true,
      commented = false,
      show_stop_reason = true,
    },
  },
}
