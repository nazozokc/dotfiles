return {
  'tttol/md-outline.nvim',
  config = function()
    require('md-outline').setup({
      auto_open = false -- default: true
    })
  end
}
