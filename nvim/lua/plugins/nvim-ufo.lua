return {
<<<<<<< HEAD
 	"kevinhwang91/nvim-ufo",
 	event = "BufReadPost",
 	dependencies = "kevinhwang91/promise-async",
 	config = function()
 		vim.o.foldcolumn = "1"
 		vim.o.foldlevel = 99
 		vim.o.foldlevelstart = 99
 		vim.o.foldenable = true

 		require("ufo").setup({
 			provider_selector = function(_, _, _)
 				return { "treesitter", "indent" }
 			end,
 		})

 		vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })
 		vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds" })
 	end,
 }
=======
  "kevinhwang91/nvim-ufo",
  event = "BufReadPost",
  dependencies = "kevinhwang91/promise-async",
  config = function()
    vim.o.foldcolumn = "1"
    vim.o.foldlevel = 99
    vim.o.foldlevelstart = 99
    vim.o.foldenable = true

    require("ufo").setup({
      provider_selector = function(_, _, _)
        return { "treesitter", "indent" }
      end,
    })

    vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })
    vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds" })
  end,
}
>>>>>>> main
