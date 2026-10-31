return {
	"SunnyTamang/select-undo.nvim",
	event = "BufReadPre",
	opts = {
		persistent_undo = true,
		mapping = true,
		line_mapping = "gu",
		sweep_mapping = "gU",
		partial_mapping = "gC",
		max_history = 100,
	},
}
