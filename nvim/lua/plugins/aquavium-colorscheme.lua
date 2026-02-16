return {
    "T-b-t-nchos/Aquavium.nvim",
    lazy = false,
    priority = 5000,
    config = function()
        local aquavium = require("Aquavium")

        aquavium.setup({
            -- options

            ---- For example,
           -- bold = false,
           -- italic = false,
           -- transparent = false,
        })

        vim.cmd("colorscheme Aquavium")
    end,
}
