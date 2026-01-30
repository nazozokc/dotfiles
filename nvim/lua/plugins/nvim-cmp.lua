return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter", -- CmdlineEnter は分離して軽量化
  dependencies = {
    -- completion sources
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",

    -- snippet
    "vim-denops/denops.vim",
    "uga-rosa/denippet.vim",
    "uga-rosa/cmp-denippet",
    "ryoppippi/denippet-autoimport-vscode",

    -- UI
    "roobert/tailwindcss-colorizer-cmp.nvim",
  },

  config = function()
    local cmp = require("cmp")

    ----------------------------------------------------------------
    -- denippet
    ----------------------------------------------------------------
    vim.g.denippet_snippet_dirs = {
      vim.fn.stdpath("config") .. "/snippets",
    }

    ----------------------------------------------------------------
    -- highlight
    ----------------------------------------------------------------
    vim.api.nvim_set_hl(0, "CmpGhostSnippet", {
      fg = "#727169",
      italic = true,
    })

    vim.api.nvim_set_hl(0, "CmpSnippetPreview", {
      fg = "#6e738d",
      italic = true,
    })

    ----------------------------------------------------------------
    -- cmp setup
    ----------------------------------------------------------------
    cmp.setup({
      preselect = cmp.PreselectMode.None, -- ← 勝手に選ばせない（軽くなる）

      snippet = {
        expand = function(args)
          vim.fn["denippet#anonymous"](args.body)
        end,
      },

      completion = {
        keyword_length = 2, -- 1文字補完を禁止（激重対策）
      },

      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },

      formatting = {
        fields = { "kind", "abbr", "menu" },
        format = function(entry, item)
          local icons = {
            Function = "󰊕",
            Snippet  = "",
          }

          item.kind = (icons[item.kind] or "") .. " " .. item.kind
          item.menu = ({
            denippet = "[SNIP]",
            nvim_lsp = "[LSP]",
            buffer   = "[BUF]",
            path     = "[PATH]",
          })[entry.source.name]

          return item
        end,
      },

      mapping = cmp.mapping.preset.insert({
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),

        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.confirm({ select = true })
          elseif vim.fn["denippet#jumpable"]() == 1 then
            vim.fn["denippet#jump"]()
          else
            fallback()
          end
        end, { "i", "s" }),

        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if vim.fn["denippet#jumpable"](-1) == 1 then
            vim.fn["denippet#jump"](-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      }),

      sources = cmp.config.sources({
        { name = "denippet", priority = 1000 },
        { name = "nvim_lsp", priority = 900 },
        { name = "path",     priority = 500 },
        { name = "buffer",   priority = 200, keyword_length = 3 }, -- buffer重い対策
      }),

      experimental = {
        ghost_text = {
          hl_group = "CmpGhostSnippet",
        },
      },
    })

    ----------------------------------------------------------------
    -- snippet preview（軽量版）
    ----------------------------------------------------------------
    local ns = vim.api.nvim_create_namespace("cmp_snippet_preview")

    cmp.event:on("complete_changed", function(event)
      vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)

      local entry = event.entry
      if not entry or entry.source.name ~= "denippet" then
        return
      end

      local snippet = entry:get_insert_text()
      if not snippet then
        return
      end

      local preview = snippet
          :gsub("%$%b{}", "")
          :gsub("%$%d+", "")
          :match("^[^\n]+")

      if not preview then
        return
      end

      local row, col = unpack(vim.api.nvim_win_get_cursor(0))
      vim.api.nvim_buf_set_extmark(0, ns, row - 1, col, {
        virt_text = { { preview, "CmpSnippetPreview" } },
        virt_text_pos = "eol",
      })
    end)

    cmp.event:on("menu_closed", function()
      vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
    end)
  end,
}
