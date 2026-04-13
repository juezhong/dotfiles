return {
    -- "catppuccin/nvim",
    -- name 用于本地插件目录并用作显示名称的插件的自定义名称，但和 require 里的名称没有关系
    -- 这里设置是为了 catppuccin 插件不和 nvim 重名
    -- name = "catppuccin",
    -- "ellisonleao/gruvbox.nvim",
    "navarasu/onedark.nvim",
    -- lazy = true,
    event = "UIEnter",
    priority = 1000,
    --[[
        旧的配置形式，在 init.lua 中直接加载然后配置
        require("catppuccin").setup()
        vim.cmd.colorscheme "catppuccin"
        现在使用 config 属性 lazy.nvim 可以直接 require 对应的包并setup
    ]]
    config = function()
        --[[ -- vim.opt.background = "light"
        vim.opt.background = "dark"
        -- vim.cmd.colorscheme = "catppuccin"
        vim.cmd.colorscheme "gruvbox"
        -- desert ]]

        require('onedark').setup  {
            -- Main options --
            style = 'warm', -- Default theme style. Choose between 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer' and 'light'
            transparent = false,  -- Show/hide background
            term_colors = true, -- Change terminal color as per the selected theme style
            ending_tildes = false, -- Show the end-of-buffer tildes. By default they are hidden
            cmp_itemkind_reverse = false, -- reverse item kind highlights in cmp menu

            -- toggle theme style ---
            -- toggle_style_key = nil, -- keybind to toggle theme style. Leave it nil to disable it, or set it to a string, for example "<leader>ts"
            toggle_style_key = "<leader>ts", -- keybind to toggle theme style. Leave it nil to disable it, or set it to a string, for example "<leader>ts"
            toggle_style_list = {'dark', 'darker', 'cool', 'deep', 'warm', 'warmer', 'light'}, -- List of styles to toggle between

            -- Change code style ---
            -- Options are italic, bold, underline, none
            -- You can configure multiple style with comma separated, For e.g., keywords = 'italic,bold'
            code_style = {
                comments = 'italic',
                keywords = 'none',
                functions = 'none',
                strings = 'none',
                variables = 'none'
            },

            -- Lualine options --
            lualine = {
                transparent = false, -- lualine center bar transparency
            },

            -- Custom Highlights --
            colors = {}, -- Override default colors
            highlights = {}, -- Override highlight groups

            -- Plugins Config --
            diagnostics = {
                darker = true, -- darker colors for diagnostic
                undercurl = true,   -- use undercurl instead of underline for diagnostics
                background = true,    -- use background color for virtual text
            },
        }
        require('onedark').load()

    end
}
