return {
  "hrsh7th/nvim-cmp",
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
    -- insert 用
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",

    -- cmdline 用（必要最低限）
    "hrsh7th/cmp-cmdline",
    "hrsh7th/cmp-path",

    -- denippet
    "uga-rosa/denippet.vim",
    "uga-rosa/cmp-denippet",
  },

  config = function()
    local cmp = require("cmp")

    ------------------------------------------------------------------
    -- denippet（最小）
    ------------------------------------------------------------------
    vim.g.denippet_snippet_dirs = {
      vim.fn.stdpath("config") .. "/snippets",
    }

    ------------------------------------------------------------------
    -- Insert mode
    ------------------------------------------------------------------
    cmp.setup({
      preselect = cmp.PreselectMode.None,

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
        ghost_text = false,
      },
    })

    ------------------------------------------------------------------
    -- Cmdline "/"
    ------------------------------------------------------------------
    cmp.setup.cmdline("/", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "buffer" },
      },
    })

    ------------------------------------------------------------------
    -- Cmdline ":"
    ------------------------------------------------------------------
    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "path" },
        { name = "cmdline" },
      },
    })
  end,
}

