return {
  "j-hui/fidget.nvim",
  event = "LspAttach",
  opts = {
    progress = {
      suppress_on_insert = true,
      ignore_empty_message = true,
      display = {
        done_ttl = 2,
        progress_icon = { "dots" },
        done_icon = "✔",
        skip_history = true,
        group_style = "Title",
        priority = 30,
      },
    },
    notification = {
      filter = vim.log.levels.WARN,
      history_size = 0,
      override_vim_notify = false,
      view = { stack_upwards = false, align = "message", line_margin = 1 },
      window = { winblend = 100, border = "none", zindex = 45, align = "bottom", relative = "editor" },
    },
    logger = { level = vim.log.levels.ERROR },
  },
}

