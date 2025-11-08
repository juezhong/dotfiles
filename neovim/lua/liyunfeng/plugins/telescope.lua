return {
    -- 'nvim-telescope/telescope.nvim', tag = '0.1.5',
-- or
    'nvim-telescope/telescope.nvim', branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' },
    --[[
        in init.lua file setup
        local telescope_builtin = require("telescope.builtin")
        vim.keymap.set('n', '<C-p>', telescope_builtin.find_files, {desc = "telescope 的内置函数“查找文件”函数按键绑定"})
        vim.keymap.set('n', '<leader>fg', telescope_builtin.live_grep, {desc = "telescope 的内置函数“实时文本匹配”函数按键绑定"})
    --]]
    -- 使用这种方式只会延迟不加载，当 required 或者延迟加载程序之一触发才会加载
    -- lazy = true,
    -- cmd = "Telescope",
    keys = {
        -- 这里的 desc 相当于 vim.keymap.set 里面的选项作用
        -- 而且这里的 按键触发延迟加载 的选项和 keymap.set 也很像
        -- 前面是要触发的按键，后面是一个可选的触发操作
        -- { "this lhs 相当于按键绑定的按键", "{this rhs 相当于按键绑定的触发操作}", desc = "Comment plugin" },
        -- 不过这里的触发操作要是 vim 的命令了，也就是 cmdline 的形式
        -- telescope 的内置函数
        {"<leader>tf", ":Telescope find_files<cr>", desc = "“查找文件”函数按键绑定"},
        {"<leader>tl", ":Telescope live_grep<cr>", desc = "“实时文本匹配”函数按键绑定"},
        -- {"<leader>tbb", ":Telescope buffers<cr>", desc = "“显示当前所有Buffer”函数按键绑定"}, -- 弃用，已使用 bufferline 插件
        {"<leader>tbf", ":Telescope current_buffer_fuzzy_find<cr>", desc = "“根据当前buffer模糊查询”函数按键绑定"},
        {"<leader>tr", ":Telescope resume<cr>", desc = "“继续上次搜索”函数按键绑定"},
        {"<leader>to", ":Telescope oldfiles<cr>", desc = "“历史打开文件”函数按键绑定"},
        {"<leader>tk", ":Telescope keymaps<cr>", desc = "“按键绑定查询”函数按键绑定"},
        {"<leader>tg", ":Telescope grep_string<cr>", desc = "“根据当前单词查询”函数按键绑定"},
        {"<leader>ta", ":Telescope builtin<cr>", desc = "“列出Telescope的所有内置命令”函数按键绑定"},
        {"<leader>tc", ":Telescope commands<cr>", desc = "“列出所有插件/用户的命令”函数按键绑定"},
        {"<leader>tvc", ":Telescope command_history<cr>", desc = "“列出历史命令”函数按键绑定"},
        {"<leader>tvo", ":Telescope vim_options<cr>", desc = "“列出当前的options”函数按键绑定"},
    },
    -- 设置打开 telescope 之后的按键映射
    -- mappings = {
    --     i = {
    --         -- ["<esc>"] = require('telescope.actions').close,
    --     },
    -- },
    config = function()
        -- local telescope_builtin = require("telescope.builtin")
        -- vim.keymap.set('n', '<C-f>', telescope_builtin.find_files, {desc = "telescope 的内置函数“查找文件”函数按键绑定"})
        -- vim.keymap.set("n", "<leader>tf", telescope_builtin.find_files, {desc = "telescope 的内置函数“查找文件”函数按键绑定"})
        -- vim.keymap.set("n", "<leader>tg", telescope_builtin.live_grep, {desc = "telescope 的内置函数“实时文本匹配”函数按键绑定"})
        -- vim.keymap.set("n", "<leader>tb", telescope_builtin.buffers, {desc = "telescope 的内置函数“所有Buffer切换”函数按键绑定"})
        -- vim.keymap.set("n", "<leader>ts", telescope_builtin.grep_string, {desc = ""})
        require('telescope').setup {
            defaults = {
                -- Default configuration for telescope goes here:
                -- config_key = value,
                mappings = {
                    i = {
                        -- 插入模式下的按键绑定设置
                        -- map actions.which_key to <C-w> (default: <C-/>)
                        -- actions.which_key shows the mappings for your picker,
                        -- e.g. git_{create, delete, ...}_branch for the git_branches picker
                        -- ["<C-w>"] = "which_key",
                        ["<C-g>"] = "close",
                        -- 默认的按键绑定
                        --[[
                            Mappings	Action
                        <C-n>/<Down>	Next item
                        <C-p>/<Up>	    Previous item
                        j/k	            Next/previous (in normal mode)
                        H/M/L	        Select High/Middle/Low (in normal mode)
                        gg/G	        Select the first/last item (in normal mode)
                        <CR>	        Confirm selection
                        <C-x>	        Go to file selection as a split
                        <C-v>	        Go to file selection as a vsplit
                        <C-t>	        Go to a file in a new tab
                        <C-u>	        Scroll up in preview window
                        <C-d>	        Scroll down in preview window
                        <C-f>	        Scroll left in preview window
                        <C-k>	        Scroll right in preview window
                        <M-f>	        Scroll left in results window
                        <M-k>	        Scroll right in results window
                        <C-/>	        Show mappings for picker actions (insert mode)
                        ?	            Show mappings for picker actions (normal mode)
                        <C-c>	        Close telescope (insert mode)
                        <Esc>	        Close telescope (in normal mode)
                        <Tab>	        Toggle selection and move to next selection
                        <S-Tab>	        Toggle selection and move to prev selection
                        <C-q>	        Send all items not filtered to quickfixlist (qflist)
                        <M-q>	        Send all selected items to qflist
                        <C-r><C-w>	    Insert cword in original window into prompt (insert mode)
                        ]]
                    }
                }
            },
            pickers = {
                -- Default configuration for builtin pickers goes here:
                -- picker_name = {
                --   picker_config_key = value,
                --   ...
                -- }
                -- Now the picker_config_key will be applied every time you call this
                -- builtin picker
            },
            extensions = {
                -- Your extension configuration goes here:
                -- extension_name = {
                --   extension_config_key = value,
                -- }
                -- please take a look at the readme of the extension you want to configure
            }
        }
    end
}
