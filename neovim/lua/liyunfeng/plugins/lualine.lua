return {
    'nvim-lualine/lualine.nvim',
    -- dependencies = { 'nvim-tree/nvim-web-devicons' },
    dependencies = {
        'nvim-tree/nvim-web-devicons',
        "navarasu/onedark.nvim",
    },
    lazy = true,
    -- ft = "*",
    -- event = "BufReadPost",
    event = {
        "BufReadPost",
        "BufEnter",
    },
    config = function()
        require("lualine").setup({
            options = {
                -- theme = 'dracula',
                theme = 'onedark',
            }
        })
    end
}
