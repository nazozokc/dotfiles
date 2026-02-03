return {
  "nvimdev/template.nvim",
  cmd = { "Template", "TemProject" },
  config = function()
    require("template").setup({
      temp_dir = "~/.config/nvim/template",
      author = "nazozo", -- お前の名前
      email = "hoge@example.com",

      -- 変数を追加
      variables = {
        ["_year_"] = function()
          return os.date("%Y")
        end,
        ["_date_"] = function()
          return os.date("%Y-%m-%d")
        end
      }
    })
  end,
}
