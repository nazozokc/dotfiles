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
    "microsoft/vscode-js-debug",
    build = "npm install --ignore-scripts",
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
      enabled = true,                   -- デフォルトで有効
      enabled_commands = true,          -- :EnableVirtualText でON/OFF可能
      highlight_changed_variables = true, -- 変化した値をハイライト
      highlight_new_as_changed = true,
      commented = false,                -- 行末に // の形で表示しない
      show_stop_reason = true,          -- 停止理由も表示
    },
  }

}
