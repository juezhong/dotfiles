return {
    -- "catppuccin/nvim",
    -- name = "catppuccin", 
    -- name 用于本地插件目录并用作显示名称的插件的自定义名称，但和 require 里的名称没有关系
    "ellisonleao/gruvbox.nvim",
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
        -- vim.cmd.colorscheme = "catppuccin"
        vim.cmd.colorscheme "gruvbox"
    end
}
