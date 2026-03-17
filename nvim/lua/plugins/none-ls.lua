<<<<<<< HEAD
	return {
 	"nvimtools/none-ls.nvim",
 	event = "LspAttach",
 	config = function()
 		local null_ls = require("null-ls")
 		null_ls.setup({
 			sources = {
 				null_ls.builtins.diagnostics.erb_lint,
 				null_ls.builtins.diagnostics.rubocop,
 				null_ls.builtins.formatting.rubocop,
 			},
 		})
 	end,
 }
=======
return {
  "nvimtools/none-ls.nvim",
  event = "LspAttach",
  config = function()
    local null_ls = require("null-ls")
    null_ls.setup({
      sources = {
        null_ls.builtins.diagnostics.erb_lint,
        null_ls.builtins.diagnostics.rubocop,
        null_ls.builtins.formatting.rubocop,
      },
    })
  end,
}
>>>>>>> main
