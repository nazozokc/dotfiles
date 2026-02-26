return {
  "nickjvandyke/opencode.nvim",
  cmd = { "OpenCode", "OC" },
  dependencies = {
    "folke/snacks.nvim",
  },
  config = function()
    vim.g.opencode_opts = {}

    vim.o.autoread = true

    vim.api.nvim_create_user_command("OC", function(opts)
      local input = opts.args
      if input and #input > 0 then
        require("opencode").ask(input .. ": ", { submit = true })
      else
        require("opencode").select()
      end
    end, { nargs = "*", desc = "OpenCode: Ask or select action" })

    vim.api.nvim_create_user_command("OpenCode", function(opts)
      local input = opts.args
      if input and #input > 0 then
        require("opencode").ask(input .. ": ", { submit = true })
      else
        require("opencode").select()
      end
    end, { nargs = "*", desc = "OpenCode: Ask or select action" })

    vim.keymap.set({ "n", "x" }, "<C-a>", function() require("opencode").ask("@this: ", { submit = true }) end,
      { desc = "Ask opencode" })
    vim.keymap.set({ "n", "x" }, "<C-x>", function() require("opencode").select() end,
      { desc = "Execute opencode action…" })
    vim.keymap.set({ "n", "t" }, "<C-.>", function() require("opencode").toggle() end, { desc = "Toggle opencode" })

    vim.keymap.set({ "n", "x" }, "go", function() return require("opencode").operator("@this ") end,
      { expr = true, desc = "Add range to opencode" })
    vim.keymap.set("n", "goo", function() return require("opencode").operator("@this ") .. "_" end,
      { expr = true, desc = "Add line to opencode" })

    vim.keymap.set("n", "<S-C-u>", function() require("opencode").command("session.half.page.up") end,
      { desc = "opencode half page up" })
    vim.keymap.set("n", "<S-C-d>", function() require("opencode").command("session.half.page.down") end,
      { desc = "opencode half page down" })

    vim.keymap.set("n", "+", "<C-a>", { desc = "Increment", noremap = true })
    vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement", noremap = true })
  end,
}
