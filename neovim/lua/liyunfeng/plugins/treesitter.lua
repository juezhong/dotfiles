return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    --[[
        in init.lua file setup
        -- equal require("nvim-treesitter.configs")
        local treesitter_config = require("nvim-treesitter/configs")
        treesitter_config.setup({
            ensure_installed = { "c", "cpp", "lua" },
            highlight = { enable = true },
            indent = { enable = true },
        })
    --]]
    -- event = "VeryLazy",
    event = "BufReadPost",
    -- lazy = true,
    config = function()
        local treesitter_config = require("nvim-treesitter.configs")
        treesitter_config.setup({
            ensure_installed = { "c", "cpp", "lua", "vim", "vimdoc", "query", "json" },
            highlight = { enable = true },
            indent = { enable = true },
            -- 根据语法中的命名节点进行增量选择
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<leader>ss", -- set to `false` to disable one of the mappings
                    node_incremental = "<leader>si",
                    node_decremental = "<leader>sd",
                    scope_incremental = "<leader>sc",
                },
            },
        })
    end
}
