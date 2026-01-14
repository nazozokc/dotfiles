return {
  -- denippet 本体
  {
    "uga-rosa/denippet.vim",
  },

  -- nvim-cmp 連携
  {
    "uga-rosa/cmp-denippet",
    dependencies = { "uga-rosa/denippet.vim" },
  },

  -- VSCodeスニペットの auto import
  {
    "ryoppippi/denippet-autoimport-vscode",
    event = { "InsertEnter", "User DenopsReady" },
    dependencies = {
      "vim-denops/denops.vim",
      "rafamadriz/friendly-snippets",   -- your favorite VS Code-like snippet collection
    },
  },
}
