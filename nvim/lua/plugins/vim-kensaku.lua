return {
  "lambdalisue/vim-kensaku",
  event = "User DenopsReady",
  dependencies = {
    "vim-denops/denops.vim",
    "lambdalisue/kensaku-search.vim",
  },
  config = function(spec)
    vim.keymap.set("c", "?", "<Plug>(kensaku-search-backward)")
    vim.keymap.set("c", "/", "<Plug>(kensaku-search-forward)")
  end,
}
