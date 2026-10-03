# nix/modules/home/programs/nvim/plugins/nixpkgs-plugins.nix
# Neovim プラグイン名 -> nixpkgs.vimPlugins の属性名。
#
# プラグイン単体の実体もバージョンも nixpkgs 側に委ねる。
# nixpkgs に無いプラグインは ./pinned-plugins.json 側 (fetchgit) に置く。
#
# 生成方法: 稼働中の Neovim から dump した plugin.url と、nixpkgs の
# meta.homepage を突き合わせて決める。nixpkgs に無いものは
# ./pinned-plugins.json へ移す。
#
# nixpkgs 側が attr を改名・削除した場合は `nix run .#lazy2nix` の
# 最後の `nix flake check --no-build` が「どのプラグインの attr が無い」かを
# 評価エラーとして出すので、そこを直してからこのファイルを編集する。
{
  "LuaSnip" = "luasnip";
  "actions-preview.nvim" = "actions-preview-nvim";
  "aerial.nvim" = "aerial-nvim";
  "barbar.nvim" = "barbar-nvim";
  "ccc.nvim" = "ccc-nvim";
  "claudecode.nvim" = "claudecode-nvim";
  "cmp-buffer" = "cmp-buffer";
  "cmp-calc" = "cmp-calc";
  "cmp-cmdline" = "cmp-cmdline";
  "cmp-nvim-lsp" = "cmp-nvim-lsp";
  "cmp-path" = "cmp-path";
  "cmp_luasnip" = "cmp_luasnip";
  "conform.nvim" = "conform-nvim";
  "denops.vim" = "denops-vim";
  "dial.nvim" = "dial-nvim";
  "diffview.nvim" = "diffview-nvim";
  "dressing.nvim" = "dressing-nvim";
  "dropbar.nvim" = "dropbar-nvim";
  "emmet-vim" = "emmet-vim";
  "fidget.nvim" = "fidget-nvim";
  "fileline.nvim" = "fileline-nvim";
  "flash.nvim" = "flash-nvim";
  "flatten.nvim" = "flatten-nvim";
  "friendly-snippets" = "friendly-snippets";
  "fzf-lua" = "fzf-lua";
  "garbage-day.nvim" = "garbage-day-nvim";
  "gitsigns.nvim" = "gitsigns-nvim";
  "hlargs.nvim" = "hlargs-nvim";
  "hlchunk.nvim" = "hlchunk-nvim";
  "incline.nvim" = "incline-nvim";
  "kanagawa.nvim" = "kanagawa-nvim";
  "lazy.nvim" = "lazy-nvim";
  "lazygit.nvim" = "lazygit-nvim";
  "lspkind.nvim" = "lspkind-nvim";
  "lspsaga.nvim" = "lspsaga-nvim";
  "lualine.nvim" = "lualine-nvim";
  "marks.nvim" = "marks-nvim";
  "mini.ai" = "mini-ai";
  "mini.comment" = "mini-comment";
  "mini.icons" = "mini-icons";
  "mini.indentscope" = "mini-indentscope";
  "mini.jump" = "mini-jump";
  "mini.nvim" = "mini-nvim";
  "mini.surround" = "mini-surround";
  "neo-tree.nvim" = "neo-tree-nvim";
  "neotest" = "neotest";
  "neotest-jest" = "neotest-jest";
  "neotest-playwright" = "neotest-playwright";
  "neotest-vitest" = "neotest-vitest";
  "noice.nvim" = "noice-nvim";
  "none-ls.nvim" = "none-ls-nvim";
  "nui.nvim" = "nui-nvim";
  "numb.nvim" = "numb-nvim";
  "nvim-autopairs" = "nvim-autopairs";
  "nvim-cmp" = "nvim-cmp";
  "nvim-coverage" = "nvim-coverage";
  "nvim-dap" = "nvim-dap";
  "nvim-dap-ui" = "nvim-dap-ui";
  "nvim-dap-virtual-text" = "nvim-dap-virtual-text";
  "nvim-dap-vscode-js" = "nvim-dap-vscode-js";
  "nvim-highlight-colors" = "nvim-highlight-colors";
  "nvim-hlslens" = "nvim-hlslens";
  "nvim-java" = "nvim-java";
  "nvim-lightbulb" = "nvim-lightbulb";
  "nvim-lspconfig" = "nvim-lspconfig";
  "nvim-neoclip.lua" = "nvim-neoclip-lua";
  "nvim-scrollbar" = "nvim-scrollbar";
  "nvim-spider" = "nvim-spider";
  "nvim-treesitter" = "nvim-treesitter";
  "nvim-treesitter-context" = "nvim-treesitter-context";
  "nvim-ts-autotag" = "nvim-ts-autotag";
  "nvim-ufo" = "nvim-ufo";
  "nvim-web-devicons" = "nvim-web-devicons";
  "nvim_context_vt" = "nvim_context_vt";
  "octo.nvim" = "octo-nvim";
  "oil-git-status.nvim" = "oil-git-status-nvim";
  "oil.nvim" = "oil-nvim";
  "open-browser.vim" = "open-browser-vim";
  "opencode.nvim" = "opencode-nvim";
  "overseer.nvim" = "overseer-nvim";
  "package-info.nvim" = "package-info-nvim";
  "plenary.nvim" = "plenary-nvim";
  "project.nvim" = "project-nvim";
  "promise-async" = "promise-async";
  "quick-scope" = "quick-scope";
  "refactoring.nvim" = "refactoring-nvim";
  "render-markdown.nvim" = "render-markdown-nvim";
  "satellite.nvim" = "satellite-nvim";
  "snacks.nvim" = "snacks-nvim";
  "spellsitter.nvim" = "spellsitter-nvim";
  "substitute.nvim" = "substitute-nvim";
  "symbols-outline.nvim" = "symbols-outline-nvim";
  "telescope-fzf-native.nvim" = "telescope-fzf-native-nvim";
  "telescope-ui-select.nvim" = "telescope-ui-select-nvim";
  "telescope.nvim" = "telescope-nvim";
  "tiny-glimmer.nvim" = "tiny-glimmer-nvim";
  "tiny-inline-diagnostic.nvim" = "tiny-inline-diagnostic-nvim";
  "todo-comments.nvim" = "todo-comments-nvim";
  "toggleterm.nvim" = "toggleterm-nvim";
  "trouble.nvim" = "trouble-nvim";
  "vim-fugitive" = "vim-fugitive";
  "vim-illuminate" = "vim-illuminate";
  "vim-repeat" = "vim-repeat";
  "vim-test" = "vim-test";
  "vimux" = "vimux";
  "visual-whitespace.nvim" = "visual-whitespace-nvim";
  "which-key.nvim" = "which-key-nvim";
  "yazi.nvim" = "yazi-nvim";
  "zen-mode.nvim" = "zen-mode-nvim";
}
