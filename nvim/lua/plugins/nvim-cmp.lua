return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    -- 最低限
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",

    -- denippet
    "uga-rosa/denippet.vim",
    "uga-rosa/cmp-denippet",
  },

  config = function()
    local cmp = require("cmp")

    -- denippet 設定（最小）
    vim.g.denippet_snippet_dirs = {
      vim.fn.stdpath("config") .. "/snippets",
    }

    cmp.setup({
      preselect = cmp.PreselectMode.None, -- ← これ地味に効く

      snippet = {
        expand = function(args)
          vim.fn["denippet#anonymous"](args.body)
        end,
      },

      window = {
        completion = cmp.config.window.bordered(),
      },

      mapping = {
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<CR>"] = cmp.mapping.confirm({ select = false }),

        ["<Tab>"] = function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif vim.fn["denippet#jumpable"]() == 1 then
            vim.fn["denippet#jump"]()
          else
            fallback()
          end
        end,

        ["<S-Tab>"] = function(fallback)
          if vim.fn["denippet#jumpable"](-1) == 1 then
            vim.fn["denippet#jump"](-1)
          else
            fallback()
          end
        end,
      },

      sources = {
        { name = "denippet", priority = 1000 },
        { name = "nvim_lsp", priority = 700 },
        {
          name = "buffer",
          priority = 200,
          option = {
            get_bufnrs = function()
              return { vim.api.nvim_get_current_buf() }
            end,
          },
        },
      },

      performance = {
        debounce = 80,
        throttle = 40,
        fetching_timeout = 200,
      },

      experimental = {
        ghost_text = false, -- ← 絶対 false
      },
    })
  end,
}
