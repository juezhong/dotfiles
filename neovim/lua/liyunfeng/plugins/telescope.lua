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
        {"<leader>tf", ":Telescope find_files<cr>", desc = "telescope 的内置函数“查找文件”函数按键绑定"},
        {"<leader>tl", ":Telescope live_grep<cr>", desc = "telescope 的内置函数“实时文本匹配”函数按键绑定"},
        -- {"<leader>tbb", ":Telescope buffers<cr>", desc = "telescope 的内置函数“显示当前所有Buffer”函数按键绑定"}, -- 弃用，已使用 bufferline 插件
        {"<leader>tbf", ":Telescope current_buffer_fuzzy_find<cr>", desc = "telescope 的内置函数“根据当前buffer模糊查询”函数按键绑定"},
        {"<leader>tr", ":Telescope resume<cr>", desc = "telescope 的内置函数“继续上次搜索”函数按键绑定"},
        {"<leader>to", ":Telescope oldfiles<cr>", desc = "telescope 的内置函数“历史打开文件”函数按键绑定"},
        {"<leader>tk", ":Telescope keymaps<cr>", desc = "telescope 的内置函数“按键绑定查询”函数按键绑定"},
        {"<leader>tg", ":Telescope grep_string<cr>", desc = "telescope 的内置函数“根据当前单词查询”函数按键绑定"},
        {"<leader>ta", ":Telescope builtin<cr>", desc = "telescope 的内置函数“列出Telescope的所有内置命令”函数按键绑定"},
        {"<leader>tc", ":Telescope commands<cr>", desc = "telescope 的内置函数“列出所有插件/用户的命令”函数按键绑定"},
        {"<leader>tvc", ":Telescope command_history<cr>", desc = "telescope 的内置函数“列出历史命令”函数按键绑定"},
        {"<leader>tvo", ":Telescope vim_options<cr>", desc = "telescope 的内置函数“列出当前的options”函数按键绑定"},
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
    end
}
