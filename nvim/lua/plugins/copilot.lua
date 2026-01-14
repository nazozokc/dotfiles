return {
  "zbirenbaum/copilot.lua",
  config = function()
    require("copilot").setup({
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = "<C-l>",
          next = "<C-n>",
          prev = "<C-p>",
          dismiss = "<C-e>",
        },
      },
      panel = { enabled = false },
    })
  end,
}
