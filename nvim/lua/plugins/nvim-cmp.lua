-- 変更点には ★ コメント付き
return {
  "hrsh7th/nvim-cmp",
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",

    -- ★ calc は遅延ロード
    { "hrsh7th/cmp-calc", event = "InsertEnter" },

    "vim-denops/denops.vim",
    "roobert/tailwindcss-colorizer-cmp.nvim",

    "uga-rosa/denippet.vim",
    "uga-rosa/cmp-denippet",
    "ryoppippi/denippet-autoimport-vscode",
  },

  config = function()
    local cmp = require("cmp")

    vim.g.denippet_snippet_dirs = {
      vim.fn.stdpath("config") .. "/snippets",
    }

    -- highlight はそのまま
    vim.api.nvim_set_hl(0, "CmpGhostSnippet", { fg = "#727169", italic = true })
    vim.api.nvim_set_hl(0, "CmpSnippetPreview", { fg = "#6e738d", italic = true })

    ------------------------------------------------------------------
    -- cmp 本体
    ------------------------------------------------------------------
    cmp.setup({
      preselect = cmp.PreselectMode.Item,

      snippet = {
        expand = function(args)
          vim.fn["denippet#anonymous"](args.body)
        end,
      },

      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },

      formatting = {
        fields = { "kind", "abbr", "menu" },
        format = function(entry, item)
          local icons = { Function = "󰊕", Snippet = "" }
          item.kind = (icons[item.kind] or "") .. " " .. item.kind
          item.menu = ({
            denippet = "[SNIP]",
            nvim_lsp = "[LSP]",
            buffer = "[BUF]",
            path = "[PATH]",
          })[entry.source.name]
          return item
        end,
      },

      mapping = cmp.mapping.preset.insert({
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
      }),

      sources = {
        { name = "denippet", priority = 1000 },
        { name = "nvim_lsp", priority = 900 },
        { name = "path", priority = 500 },
        {
          name = "buffer",
          priority = 250,
          -- ★ 現在のバッファのみ
          option = {
            get_bufnrs = function()
              return { vim.api.nvim_get_current_buf() }
            end,
          },
        },
      },

      -- ★ 明示的にパフォーマンス制御
      performance = {
        debounce = 80,
        throttle = 40,
        fetching_timeout = 200,
      },

      experimental = {
        ghost_text = {
          hl_group = "CmpGhostSnippet",
        },
      },
    })

    ------------------------------------------------------------------
    -- ★ snippet preview（条件付き）
    ------------------------------------------------------------------
    local ns = vim.api.nvim_create_namespace("cmp_snippet_preview")

    cmp.event:on("confirm_done", function(event)
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
        :gsub("%$%b{}", function(s) return s:match("{(.-)}") or "" end)
        :gsub("%$%d+", "")
        :gsub("\n.*", "")

      local row, col = unpack(vim.api.nvim_win_get_cursor(0))
      vim.api.nvim_buf_set_extmark(0, ns, row - 1, col, {
        virt_text = { { preview, "CmpSnippetPreview" } },
        virt_text_pos = "eol",
      })
    end)

    ------------------------------------------------------------------
    -- cmdline（そのまま）
    ------------------------------------------------------------------
    cmp.setup.cmdline("/", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = { { name = "buffer" } },
    })

    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "path" },
        { name = "cmdline" },
      },
    })
  end,
}

