return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<cr>",          desc = "Diff: Open" },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Diff: File History" },
    { "<leader>gH", "<cmd>DiffviewFileHistory<cr>",   desc = "Diff: Branch History" },
    { "<leader>gc", "<cmd>DiffviewClose<cr>",         desc = "Diff: Close" },
  },
  opts = {
    enhanced_diff_hl = true, -- 変更箇所をより細かくハイライト
    show_help_hints = false,  -- ヒント表示はうるさいので消す
    watch_index = true,

    -- diff表示はverticalの方が縦長モニターじゃなくても読みやすい
    view = {
      default = {
        layout = "diff2_vertical",
        disable_diagnostics = true, -- diff中はLSPエラー表示を切る
      },
      merge_tool = {
        layout = "diff3_horizontal",
        disable_diagnostics = true,
        winbar_info = true,
      },
      file_history = {
        layout = "diff2_vertical",
        disable_diagnostics = true,
      },
    },

    file_panel = {
      listing_style = "tree",
      tree_options = {
        flatten_dirs = true,
        folder_statuses = "only_folded",
      },
      win_config = {
        position = "left",
        width = 30, -- デフォルト35より少し狭く
      },
    },

    file_history_panel = {
      win_config = {
        position = "bottom",
        height = 12,
      },
    },

    -- diff bufferのローカル設定をhookで上書き
    hooks = {
      diff_buf_read = function(bufnr)
        vim.opt_local.wrap = false
        vim.opt_local.relativenumber = false
      end,
    },

    keymaps = {
      disable_defaults = false,
      view = {
        -- デフォルトのtab/s-tabはそのまま使う
        -- コンフリクト解消を直感的に
        { "n", "<leader>co", require("diffview.actions").conflict_choose("ours"),   { desc = "Choose OURS" } },
        { "n", "<leader>ct", require("diffview.actions").conflict_choose("theirs"), { desc = "Choose THEIRS" } },
        { "n", "<leader>ca", require("diffview.actions").conflict_choose("all"),    { desc = "Choose ALL" } },
        { "n", "dx",         require("diffview.actions").conflict_choose("none"),   { desc = "Delete conflict" } },
      },
    },
  },
},
