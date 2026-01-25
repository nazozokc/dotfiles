return {
  "alexghergh/nvim-tmux-navigation",
  cmd = {
    "NvimTmuxNavigateLeft",
    "NvimTmuxNavigateDown",
    "NvimTmuxNavigateUp",
    "NvimTmuxNavigateRight",
  },
  config = function()
    require('nvim-tmux-navigation').setup({})
  end,
}
