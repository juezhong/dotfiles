return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    -- lazy = true,
    -- ft = "*",
    -- event = "BufReadPost",
    event = {
        "BufReadPost",
        "BufEnter",
    },
    config = function()
        require("lualine").setup({
            options = {
                theme = 'dracula',
            }
        })
    end
}
