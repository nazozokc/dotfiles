return {
	"hrsh7th/cmp-cmdline",
	event = "CmdlineEnter",
	-- dependencies に nvim-cmp を書かない
	--- PATCH: vim.fn.getcompletion() が nil を返すケースへの対応
	--- Neovim 0.12 の vim.validate が nil を許容しないため
	--- 該当箇所: cmp_cmdline/init.lua:136 に nil ガードを追加
	config = function()
		local ok, cmp = pcall(require, "cmp")
		if not ok then
			return
		end -- cmp未ロードなら何もしない

		cmp.setup.cmdline("/", {
			mapping = cmp.mapping.preset.cmdline(),
			sources = cmp.config.sources({
				{ name = "buffer" },
			}),
			completion = { completeopt = "menu,menuone,noselect" },
		})

		cmp.setup.cmdline(":", {
			mapping = cmp.mapping.preset.cmdline(),
			sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
			completion = { completeopt = "menu,menuone,noselect" },
		})
	end,
}
