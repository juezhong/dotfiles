return {
    'numToStr/Comment.nvim',
    lazy = false,
    keys = {
        -- "gc",
        -- "gb",
        -- 这里的 desc 相当于 vim.keymap.set 里面的选项作用
        -- 而且这里的 按键触发延迟加载 的选项和 keymap.set 也很像
        -- 前面是要触发的按键，后面是一个可选的触发操作
        -- { "this lhs 相当于按键绑定的按键", "{this rhs 相当于按键绑定的触发操作}", desc = "Comment plugin" },
        -- 不过这里的触发操作要是 vim 的命令了，也就是 cmdline 的形式
        -- example
        -- {"<leader>tf", "<cmd>Telescope find_files<cr>", desc = "telescope 的内置函数“查找文件”函数按键绑定"},
        -- {"<leader>tg", "<cmd>Telescope live_grep<cr>", desc = "telescope 的内置函数“实时文本匹配”函数按键绑定"},
        -- {"<leader>tb", "<cmd>Telescope buffers<cr>", desc = "telescope 的内置函数“所有Buffer切换”函数按键绑定"},
    },
    --[[ opts 应是一个表格（将与父规范合并）、返回一个表格（替换父规范）或更改一个表格。
    表格将传递给 Plugin.config() 函数。设置该值将意味着 Plugin.config() ]]
    opts = {
        -- add any options here
        -- 不需要多余的 {} 了
        -- {
        -- Add a space b/w comment and the line
        padding = true,
        -- Whether the cursor should stay at its position
        sticky = true,
        -- Lines to be ignored while (un)comment
        ignore = nil,
        -- LHS of toggle mappings in NORMAL mode
        toggler = {
            -- Line-comment toggle keymap
            line = 'gcc',
            -- Block-comment toggle keymap
            block = 'gbc',
        },
        -- LHS of operator-pending mappings in NORMAL and VISUAL mode
        opleader = {
            -- Line-comment keymap
            line = 'gc',
            -- Block-comment keymap
            block = 'gb',
        },
        -- LHS of extra mappings
        extra = {
            -- Add comment on the line above
            above = 'gcO',
            -- Add comment on the line below
            below = 'gco',
            -- Add comment at the end of line
            eol = 'gcA',
        },
        -- Enable keybindings
        -- NOTE: If given `false` then the plugin won't create any mappings
        mappings = {
            -- Operator-pending mapping; `gcc` `gbc` `gc[count]{motion}` `gb[count]{motion}`
            basic = true,
            -- Extra mapping; `gco`, `gcO`, `gcA`
            extra = true,
        },
        -- Function to call before (un)comment
        pre_hook = nil,
        -- Function to call after (un)comment
        post_hook = nil,
        -- }
    },
}
