-- Cargo.toml 管理 (crates.io のバージョン補完・アップデート)
return {
	{
		"Saecki/crates.nvim",
		event = { "BufRead Cargo.toml" },
		config = function()
			require("crates").setup({})
		end,
	},
}
