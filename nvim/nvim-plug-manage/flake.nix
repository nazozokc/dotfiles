# nvim/nvim-plug-manage/flake.nix
#
# Neovim プラグインの「実体とバージョン」を flake input で持つ。
# 正本はこのディレクトリの flake.lock (rev と narHash)。
#
#   追加  : ここへ input を足して `(cd nvim/nvim-plug-manage && nix flake lock)`
#   更新  : nix run .#nvim-update
#   適用  : nix run .#switch
#
# 入力名は必ず lazy.nvim の plugin.name と一致させること
# (nvim/lua/plugins/*.lua の名前。farm がそのままリンク名にする)。
#
# flake = false : プラグインはただのソース木なので flake としては扱わない。
# ビルドは nvim/modules/home/programs/nvim/plugins/default.nix が行い、
# flake.lock の narHash をそのまま fetchFromGitHub/fetchgit のハッシュに使う。
{
  description = "Neovim plugin sources (single source of truth = flake.lock)";

  inputs = {
    "Comment.nvim" = {
      url = "github:numToStr/Comment.nvim";
      flake = false;
    };
    "LuaSnip" = {
      url = "github:L3MON4D3/LuaSnip";
      flake = false;
    };
    "actions-preview.nvim" = {
      url = "github:aznhe21/actions-preview.nvim";
      flake = false;
    };
    "aerial.nvim" = {
      url = "github:stevearc/aerial.nvim";
      flake = false;
    };
    "barbar.nvim" = {
      url = "github:romgrk/barbar.nvim";
      flake = false;
    };
    "ccc.nvim" = {
      url = "github:uga-rosa/ccc.nvim";
      flake = false;
    };
    "claudecode.nvim" = {
      url = "github:coder/claudecode.nvim";
      flake = false;
    };
    "cmp-buffer" = {
      url = "github:hrsh7th/cmp-buffer";
      flake = false;
    };
    "cmp-calc" = {
      url = "github:hrsh7th/cmp-calc";
      flake = false;
    };
    "cmp-cmdline" = {
      url = "github:hrsh7th/cmp-cmdline";
      flake = false;
    };
    "cmp-nvim-lsp" = {
      url = "github:hrsh7th/cmp-nvim-lsp";
      flake = false;
    };
    "cmp-path" = {
      url = "github:hrsh7th/cmp-path";
      flake = false;
    };
    "cmp_luasnip" = {
      url = "github:saadparwaiz1/cmp_luasnip";
      flake = false;
    };
    "conform.nvim" = {
      url = "github:stevearc/conform.nvim";
      flake = false;
    };
    "cpicker.nvim" = {
      url = "github:wsdjeg/cpicker.nvim";
      flake = false;
    };
    "denops-signature_help" = {
      url = "github:matsui54/denops-signature_help";
      flake = false;
    };
    "dial.nvim" = {
      url = "github:monaqa/dial.nvim";
      flake = false;
    };
    "diffview.nvim" = {
      url = "github:sindrets/diffview.nvim";
      flake = false;
    };
    "dressing.nvim" = {
      url = "github:stevearc/dressing.nvim";
      flake = false;
    };
    "dropbar.nvim" = {
      url = "github:Bekaboo/dropbar.nvim";
      flake = false;
    };
    "emmet-vim" = {
      url = "github:mattn/emmet-vim";
      flake = false;
    };
    "eslint.nvim" = {
      url = "github:MunifTanjim/eslint.nvim";
      flake = false;
    };
    "fidget.nvim" = {
      url = "github:j-hui/fidget.nvim";
      flake = false;
    };
    "fileline.nvim" = {
      url = "github:lewis6991/fileline.nvim";
      flake = false;
    };
    "flash.nvim" = {
      url = "github:folke/flash.nvim";
      flake = false;
    };
    "flatten.nvim" = {
      url = "github:willothy/flatten.nvim";
      flake = false;
    };
    "friendly-snippets" = {
      url = "github:rafamadriz/friendly-snippets";
      flake = false;
    };
    "fzf-lua" = {
      url = "github:ibhagwan/fzf-lua";
      flake = false;
    };
    "garbage-day.nvim" = {
      url = "github:Zeioth/garbage-day.nvim";
      flake = false;
    };
    "gitsigns.nvim" = {
      url = "github:lewis6991/gitsigns.nvim";
      flake = false;
    };
    "hlargs.nvim" = {
      url = "github:m-demare/hlargs.nvim";
      flake = false;
    };
    "hlchunk.nvim" = {
      url = "github:shellRaining/hlchunk.nvim";
      flake = false;
    };
    "incline.nvim" = {
      url = "github:b0o/incline.nvim";
      flake = false;
    };
    "indent-blankline.nvim" = {
      url = "github:lukas-reineke/indent-blankline.nvim";
      flake = false;
    };
    "jumpcursor.vim" = {
      url = "github:skanehira/jumpcursor.vim";
      flake = false;
    };
    "kanagawa.nvim" = {
      url = "github:rebelot/kanagawa.nvim";
      flake = false;
    };
    "kensaku-search.vim" = {
      url = "github:lambdalisue/kensaku-search.vim";
      flake = false;
    };
    "lazygit.nvim" = {
      url = "github:kdheepak/lazygit.nvim";
      flake = false;
    };
    "logger.nvim" = {
      url = "github:wsdjeg/logger.nvim";
      flake = false;
    };
    "lsp_lines.nvim" = {
      url = "git+https://git.sr.ht/~whynothugo/lsp_lines.nvim";
      flake = false;
    };
    "lspkind.nvim" = {
      url = "github:onsails/lspkind.nvim";
      flake = false;
    };
    "lspsaga.nvim" = {
      url = "github:nvimdev/lspsaga.nvim";
      flake = false;
    };
    "lualine.nvim" = {
      url = "github:nvim-lualine/lualine.nvim";
      flake = false;
    };
    "marks.nvim" = {
      url = "github:chentoast/marks.nvim";
      flake = false;
    };
    "md-outline.nvim" = {
      url = "github:tttol/md-outline.nvim";
      flake = false;
    };
    "mini.ai" = {
      url = "github:nvim-mini/mini.ai";
      flake = false;
    };
    "mini.comment" = {
      url = "github:nvim-mini/mini.comment";
      flake = false;
    };
    "mini.icons" = {
      url = "github:nvim-mini/mini.icons";
      flake = false;
    };
    "mini.indentscope" = {
      url = "github:nvim-mini/mini.indentscope";
      flake = false;
    };
    "mini.jump" = {
      url = "github:nvim-mini/mini.jump";
      flake = false;
    };
    "mini.nvim" = {
      url = "github:nvim-mini/mini.nvim";
      flake = false;
    };
    "mini.surround" = {
      url = "github:nvim-mini/mini.surround";
      flake = false;
    };
    "modes.nvim" = {
      url = "github:mvllow/modes.nvim";
      flake = false;
    };
    "neo-tree.nvim" = {
      url = "github:nvim-neo-tree/neo-tree.nvim";
      flake = false;
    };
    "neotest" = {
      url = "github:nvim-neotest/neotest";
      flake = false;
    };
    "neotest-jest" = {
      url = "github:nvim-neotest/neotest-jest";
      flake = false;
    };
    "neotest-playwright" = {
      url = "github:thenbe/neotest-playwright";
      flake = false;
    };
    "neotest-vitest" = {
      url = "github:marilari88/neotest-vitest";
      flake = false;
    };
    "noice.nvim" = {
      url = "github:folke/noice.nvim";
      flake = false;
    };
    "none-ls.nvim" = {
      url = "github:nvimtools/none-ls.nvim";
      flake = false;
    };
    "notify.nvim" = {
      url = "github:wsdjeg/notify.nvim";
      flake = false;
    };
    "nui.nvim" = {
      url = "github:MunifTanjim/nui.nvim";
      flake = false;
    };
    "numb.nvim" = {
      url = "github:nacro90/numb.nvim";
      flake = false;
    };
    "nvim-autopairs" = {
      url = "github:windwp/nvim-autopairs";
      flake = false;
    };
    "nvim-cmp" = {
      url = "github:hrsh7th/nvim-cmp";
      flake = false;
    };
    "nvim-coverage" = {
      url = "github:andythigpen/nvim-coverage";
      flake = false;
    };
    "nvim-dap" = {
      url = "git+https://codeberg.org/mfussenegger/nvim-dap";
      flake = false;
    };
    "nvim-dap-ui" = {
      url = "github:rcarriga/nvim-dap-ui";
      flake = false;
    };
    "nvim-dap-virtual-text" = {
      url = "github:theHamsta/nvim-dap-virtual-text";
      flake = false;
    };
    "nvim-dap-vscode-js" = {
      url = "github:mxsdev/nvim-dap-vscode-js";
      flake = false;
    };
    "nvim-highlight-colors" = {
      url = "github:brenoprata10/nvim-highlight-colors";
      flake = false;
    };
    "nvim-hlslens" = {
      url = "github:kevinhwang91/nvim-hlslens";
      flake = false;
    };
    "nvim-java" = {
      url = "github:nvim-java/nvim-java";
      flake = false;
    };
    "nvim-lightbulb" = {
      url = "github:kosayoda/nvim-lightbulb";
      flake = false;
    };
    "nvim-lspconfig" = {
      url = "github:neovim/nvim-lspconfig";
      flake = false;
    };
    "nvim-neoclip.lua" = {
      url = "github:AckslD/nvim-neoclip.lua";
      flake = false;
    };
    "nvim-notify" = {
      url = "github:rcarriga/nvim-notify";
      flake = false;
    };
    "nvim-pnpm-catalog-lens" = {
      url = "github:ryoppippi/nvim-pnpm-catalog-lens";
      flake = false;
    };
    "nvim-scrollbar" = {
      url = "github:petertriho/nvim-scrollbar";
      flake = false;
    };
    "nvim-spider" = {
      url = "github:chrisgrieser/nvim-spider";
      flake = false;
    };
    "nvim-tmux-navigation" = {
      url = "github:alexghergh/nvim-tmux-navigation";
      flake = false;
    };
    "nvim-treesitter" = {
      url = "github:nvim-treesitter/nvim-treesitter";
      flake = false;
    };
    "nvim-treesitter-context" = {
      url = "github:nvim-treesitter/nvim-treesitter-context";
      flake = false;
    };
    "nvim-ts-autotag" = {
      url = "github:windwp/nvim-ts-autotag";
      flake = false;
    };
    "nvim-ufo" = {
      url = "github:kevinhwang91/nvim-ufo";
      flake = false;
    };
    "nvim-web-devicons" = {
      url = "github:nvim-tree/nvim-web-devicons";
      flake = false;
    };
    "nvim_context_vt" = {
      url = "github:andersevenrud/nvim_context_vt";
      flake = false;
    };
    "octo.nvim" = {
      url = "github:pwntester/octo.nvim";
      flake = false;
    };
    "oil-git-status.nvim" = {
      url = "github:refractalize/oil-git-status.nvim";
      flake = false;
    };
    "oil.nvim" = {
      url = "github:stevearc/oil.nvim";
      flake = false;
    };
    "open-browser.vim" = {
      url = "github:tyru/open-browser.vim";
      flake = false;
    };
    "opencode.nvim" = {
      url = "github:nickjvandyke/opencode.nvim";
      flake = false;
    };
    "overseer.nvim" = {
      url = "github:stevearc/overseer.nvim";
      flake = false;
    };
    "package-info.nvim" = {
      url = "github:vuki656/package-info.nvim";
      flake = false;
    };
    "plenary.nvim" = {
      url = "github:nvim-lua/plenary.nvim";
      flake = false;
    };
    "project.nvim" = {
      url = "github:DrKJeff16/project.nvim";
      flake = false;
    };
    "promise-async" = {
      url = "github:kevinhwang91/promise-async";
      flake = false;
    };
    "quick-scope" = {
      url = "github:unblevable/quick-scope";
      flake = false;
    };
    "refactoring.nvim" = {
      url = "github:theprimeagen/refactoring.nvim";
      flake = false;
    };
    "render-markdown.nvim" = {
      url = "github:MeanderingProgrammer/render-markdown.nvim";
      flake = false;
    };
    "rust-tools.nvim" = {
      url = "github:simrat39/rust-tools.nvim";
      flake = false;
    };
    "satellite.nvim" = {
      url = "github:lewis6991/satellite.nvim";
      flake = false;
    };
    "select-undo.nvim" = {
      url = "github:SunnyTamang/select-undo.nvim";
      flake = false;
    };
    "snacks.nvim" = {
      url = "github:folke/snacks.nvim";
      flake = false;
    };
    "spellsitter.nvim" = {
      url = "github:lewis6991/spellsitter.nvim";
      flake = false;
    };
    "substitute.nvim" = {
      url = "github:gbprod/substitute.nvim";
      flake = false;
    };
    "swagger-preview.nvim" = {
      url = "github:vinnymeller/swagger-preview.nvim";
      flake = false;
    };
    "symbols-outline.nvim" = {
      url = "github:simrat39/symbols-outline.nvim";
      flake = false;
    };
    "tailwindcss-colorizer-cmp.nvim" = {
      url = "github:roobert/tailwindcss-colorizer-cmp.nvim";
      flake = false;
    };
    "telescope-ui-select.nvim" = {
      url = "github:nvim-telescope/telescope-ui-select.nvim";
      flake = false;
    };
    "telescope.nvim" = {
      url = "github:nvim-telescope/telescope.nvim";
      flake = false;
    };
    "tiny-glimmer.nvim" = {
      url = "github:rachartier/tiny-glimmer.nvim";
      flake = false;
    };
    "tiny-inline-diagnostic.nvim" = {
      url = "github:rachartier/tiny-inline-diagnostic.nvim";
      flake = false;
    };
    "todo-comments.nvim" = {
      url = "github:folke/todo-comments.nvim";
      flake = false;
    };
    "toggleterm.nvim" = {
      url = "github:akinsho/toggleterm.nvim";
      flake = false;
    };
    "translate.nvim" = {
      url = "github:uga-rosa/translate.nvim";
      flake = false;
    };
    "trouble.nvim" = {
      url = "github:folke/trouble.nvim";
      flake = false;
    };
    "ts-error-translator.nvim" = {
      url = "github:dmmulroy/ts-error-translator.nvim";
      flake = false;
    };
    "ts-expand-hover.nvim" = {
      url = "github:nemanjamalesija/ts-expand-hover.nvim";
      flake = false;
    };
    "utf8.nvim" = {
      url = "github:uga-rosa/utf8.nvim";
      flake = false;
    };
    "vim-bad-apple" = {
      url = "github:ryoppippi/vim-bad-apple";
      flake = false;
    };
    "vim-fugitive" = {
      url = "github:tpope/vim-fugitive";
      flake = false;
    };
    "vim-illuminate" = {
      url = "github:RRethy/vim-illuminate";
      flake = false;
    };
    "vim-kensaku" = {
      url = "github:lambdalisue/vim-kensaku";
      flake = false;
    };
    "vim-repeat" = {
      url = "github:tpope/vim-repeat";
      flake = false;
    };
    "vim-sonictemplate" = {
      url = "github:mattn/vim-sonictemplate";
      flake = false;
    };
    "vim-svelte-inspector" = {
      url = "github:ryoppippi/vim-svelte-inspector";
      flake = false;
    };
    "vim-test" = {
      url = "github:vim-test/vim-test";
      flake = false;
    };
    "vimux" = {
      url = "github:preservim/vimux";
      flake = false;
    };
    "visual-whitespace.nvim" = {
      url = "github:mcauley-penney/visual-whitespace.nvim";
      flake = false;
    };
    "vscode-js-debug" = {
      url = "github:microsoft/vscode-js-debug";
      flake = false;
    };
    "which-key.nvim" = {
      url = "github:folke/which-key.nvim";
      flake = false;
    };
    "wordcount.nvim" = {
      url = "github:nazozokc/wordcount.nvim";
      flake = false;
    };
    "yazi.nvim" = {
      url = "github:mikavilpas/yazi.nvim";
      flake = false;
    };
    "zen-mode.nvim" = {
      url = "github:folke/zen-mode.nvim";
      flake = false;
    };
    "zls" = {
      url = "github:zigtools/zls";
      flake = false;
    };
  };

  # プラグインは flake ではないので outputs は空。
  # 使われるのは flake.lock のみ。
  outputs = _: { };
}
