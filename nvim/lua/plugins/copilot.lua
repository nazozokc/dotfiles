return {
  "zbirenbaum/copilot.lua",
  event = "InsertEnter",
  config = function()
    require("copilot").setup({
      suggestion = {
        enabled = true,
        auto_trigger = true,
        -- Avoid conflicts with window navigation (<C-h/j/k/l>) and common completion keys (<C-n>/<C-p>).
        keymap = {
          accept = "<M-l>",
          next = "<M-n>",
          prev = "<M-p>",
          dismiss = "<M-e>",
        },
      },
      panel = { enabled = false },
    })
  end,
}
