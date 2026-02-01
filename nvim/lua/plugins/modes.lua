return {
  {
    "mvllow/modes.nvim",
    event = "VimEnter", -- 遅延読み込み
    config = function()
      require("modes").setup({
        -- 各モードの色
        colors = {
          normal = "#8be9fd",
          insert = "#ff5555",
          visual = "#bd93f9",
          command = "#00000",
          replace = "#ff79c6",
          terminal = "#ffffff",
        },
        -- どのハイライトを変えるか
        line_nr = true,        -- 行番号
        cursor_line_nr = true, -- カーソル行の番号
      })
    end
  }
}
