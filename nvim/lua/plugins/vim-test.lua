return {
  "vim-test/vim-test",
  event = "InsertEnter",
  dependencies = {
    "preservim/vimux"
  },
  config = function()
    vim.keymap.set("n", "<leader>vt", ":TestNearest<CR>", {})
    vim.keymap.set("n", "<leader>T", ":TestFile<CR>", {})
    vim.keymap.set("n", "<leader>a", ":TestSuite<CR>", {})
    vim.keymap.set("n", "<leader>l", ":TestLast<CR>", {})
    vim.keymap.set("n", "<leader>g", ":TestVisit<CR>", {})
    vim.cmd("let test#strategy = 'vimux'")
  end,
}
