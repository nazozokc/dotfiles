return {
	{
		-- nixpkgs 版は新 API (rework)。ensure_installed / highlight opts はもう無い。
		-- parser の実体は nix module が TREESITTER_GRAMMARS に置き、ここで
		-- runtimepath へ足す。nvim 0.11+ は parser が rtp にあれば
		-- FileType で自動ハイライトを始める。
		"nvim-treesitter/nvim-treesitter",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			local grammars = os.getenv("TREESITTER_GRAMMARS") or ""
			if grammars ~= "" and vim.uv.fs_stat(grammars .. "/parser") ~= nil then
				vim.opt.runtimepath:append(grammars)
				-- BufReadPost で lazy が動くのは FileType 自動ハイライトの
				-- 試行より後。parser の追加で開き直せなかったバッファを
				-- 先頭バッファ分だけ拾う。
				for _, buf in ipairs(vim.api.nvim_list_bufs()) do
					if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype ~= "" then
						pcall(vim.treesitter.start, buf)
					end
				end
			end
		end,
	},
}
