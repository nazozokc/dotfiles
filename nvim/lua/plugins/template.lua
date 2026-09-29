return {
	"mattn/vim-sonictemplate",
	cmd = { "Template" },
	keys = {
		{ "tmp", "Template", mode = "ca" },
	},
	-- autoload/sonictemplate.vim は初回の autoload 時に s:tmpldir を確定させる。
	-- そのため g:sonictemplate_* は config() ではなく init() で設定する。
	init = function()
		vim.g.sonictemplate_key = 0
		vim.g.sonictemplate_intelligent_key = 0
		vim.g.sonictemplate_postfix_key = 0

		vim.g.sonictemplate_vim_template_dir = { vim.fn.stdpath("config") .. "/template" }
	end,
	config = function()
		local function git(key)
			local out = vim.fn.system({ "git", "config", "--get", key })
			if vim.v.shell_error ~= 0 then
				return ""
			end
			return vim.trim(out)
		end

		-- git 未設定の環境でも固まらないようにフォールバックを置く
		local name = git("user.name")

		vim.g.sonictemplate_vim_vars = {
			_ = {
				author = name ~= "" and name or "nazozokc",
			},
		}
	end,
}
