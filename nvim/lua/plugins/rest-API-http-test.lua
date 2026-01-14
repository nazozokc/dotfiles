return {
  "rest-nvim/rest.nvim",
  ft = { "http" },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    -- Telescope使ってるなら
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    require("rest-nvim").setup({
      -- ==========
      -- リクエスト
      -- ==========
      request = {
        skip_ssl_verification = false, -- 自宅なら切る理由なし
        timeout = 30000,               -- API遅くても待つ
      },

      -- ==========
      -- レスポンス表示
      -- ==========
      response = {
        hooks = {
          format = true, -- JSON整形ON
        },
      },

      -- ==========
      -- .env 管理
      -- ==========
      env = {
        enable = true,
        pattern = ".*%.env.*", -- .env / .env.local / .env.dev 全対応
      },

      -- ==========
      -- UI
      -- ==========
      ui = {
        winbar = true, -- 今どのenvか見える
        highlight = {
          enabled = true,
          timeout = 750,
        },
      },
    })

    -- ==========
    -- キーマップ（超重要）
    -- ==========
    local map = vim.keymap.set

    map("n", "<leader>rr", "<cmd>Rest run<CR>", { desc = "REST: run request" })
    map("n", "<leader>rl", "<cmd>Rest last<CR>", { desc = "REST: run last" })
    map("n", "<leader>ro", "<cmd>Rest open<CR>", { desc = "REST: open result" })
    map("n", "<leader>re", "<cmd>Rest env show<CR>", { desc = "REST: show env" })

    -- Telescope 連携（入れてるなら）
    pcall(function()
      require("telescope").load_extension("rest")
      map("n", "<leader>rs", "<cmd>Telescope rest select_env<CR>",
        { desc = "REST: select env" })
    end)
  end,
}
