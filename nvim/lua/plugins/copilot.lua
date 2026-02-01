return {
  "zbirenbaum/copilot.lua",
  event = "InsertEnter",
  config = function()
    require("copilot").setup({
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = false, -- ← Copilot側ではTabを使わない
        },
      },
      panel = { enabled = false },
    })

    -- Tab を自前で制御する
    vim.keymap.set("i", "<Tab>", function()
      local copilot = require("copilot.suggestion")
      if copilot.is_visible() then
        copilot.accept()
        return ""
      else
        return "<Tab>"
      end
    end, { expr = true, silent = true })
  end,
}

