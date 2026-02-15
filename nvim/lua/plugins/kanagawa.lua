return {
  "rebelot/kanagawa.nvim",
  priority = 5000,
  config = function()
    require("kanagawa").setup({
      transparent = true, -- これが本体
      colors = {
        theme = {
          all = {
            ui = {
              bg_gutter = "none", -- 行番号周りも透過
            },
          },
        },
      },
    })

    vim.cmd.colorscheme("kanagawa-dragon")
  end,
}

