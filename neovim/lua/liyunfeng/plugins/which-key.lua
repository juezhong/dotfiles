return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    -- lazy = true,
    init = function()
        vim.o.timeout = true
        vim.o.timeoutlen = 500
    end,
    opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
    },
    plugins = {
        marks = true, -- shows a list of your marks on ' and `
        registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
        -- the presets plugin, adds help for a bunch of default keybindings in Neovim
        -- No actual key bindings are created
        spelling = {
            enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
            suggestions = 20, -- how many suggestions should be shown in the list?
        },
        presets = {
            operators = true, -- adds help for operators like d, y, ...
            motions = true, -- adds help for motions
            text_objects = true, -- help for text objects triggered after entering an operator
            windows = true, -- default bindings on <c-w>
            nav = true, -- misc bindings to work with windows
            z = true, -- bindings for folds, spelling and others prefixed with z
            g = true, -- bindings for prefixed with g
        },
    },
    -- add operators that will trigger motion and text object completion
    -- to enable all native operators, set the preset / operators plugin above
    operators = { gc = "Comments" },
    key_labels = {
        -- override the label used to display some keys. It doesn't effect WK in any other way.
        -- For example:
        -- ["<space>"] = "SPC",
        -- ["<cr>"] = "RET",
        -- ["<tab>"] = "TAB",
    },
    motions = {
        count = true,
    },
    icons = {
        breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
        separator = "➜", -- symbol used between a key and it's label
        group = "+", -- symbol prepended to a group
    },
    popup_mappings = {
        scroll_down = "<c-d>", -- binding to scroll down inside the popup
        scroll_up = "<c-u>", -- binding to scroll up inside the popup
    },
    window = {
        -- border = "none", -- none, single, double, shadow
        border = "single", -- none, single, double, shadow
        -- position = "bottom", -- bottom, top
        position = "top", -- bottom, top
        margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]. When between 0 and 1, will be treated as a percentage of the screen size.
        padding = { 1, 2, 1, 2 }, -- extra window padding [top, right, bottom, left]
        winblend = 0, -- value between 0-100 0 for fully opaque and 100 for fully transparent
        zindex = 1000, -- positive value to position WhichKey above other floating windows.
    },
    layout = {
        height = { min = 4, max = 25 }, -- min and max height of the columns
        width = { min = 20, max = 50 }, -- min and max width of the columns
        spacing = 3, -- spacing between columns
        align = "left", -- align columns left, center or right
    },
    ignore_missing = false, -- enable this to hide mappings for which you didn't specify a label
    hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "^:", "^ ", "^call ", "^lua " }, -- hide mapping boilerplate
    show_help = true, -- show a help message in the command line for using WhichKey
    show_keys = true, -- show the currently pressed key and its label as a message in the command line
    triggers = "auto", -- automatically setup triggers
    -- triggers = {"<leader>"} -- or specifiy a list manually
    -- list of triggers, where WhichKey should not wait for timeoutlen and show immediately
    triggers_nowait = {
        -- marks
        "`",
        "'",
        "g`",
        "g'",
        -- registers
        '"',
        "<c-r>",
        -- spelling
        "z=",
    },
    triggers_blacklist = {
        -- list of mode / prefixes that should never be hooked by WhichKey
        -- this is mostly relevant for keymaps that start with a native binding
        i = { "j", "k" },
        v = { "j", "k" },
    },
    -- disable the WhichKey popup for certain buf types and file types.
    -- Disabled by default for Telescope
    disable = {
        buftypes = {},
        filetypes = {},
    },
    config = function()
        local wk = require("which-key")
        -- As an example, we will create the following mappings:
        --  * <leader>ff find files
        --  * <leader>fr show recent files
        --  * <leader>fb Foobar
        -- we'll document:
        --  * <leader>fn new file
        --  * <leader>fe edit file
        -- and hide <leader>1

        -- wk.register({
        --     f = {
        --         name = "Files", -- optional group name
        --         -- f = { "<cmd>Telescope find_files<cr>", "Find File" }, -- create a binding with label
        --         -- r = { "<cmd>Telescope oldfiles<cr>", "Open Recent File", noremap=false, buffer = 123 }, -- additional options for creating the keymap
        --         -- n = { "New File" }, -- just a label. don't create any mapping
        --         -- e = "Edit File", -- same as above
        --         -- ["1"] = "which_key_ignore",  -- special label to hide it in the popup
        --         -- b = { function() print("bar") end, "Foobar" } -- you can also pass functions!
        --         -- 这部分与 telescope 的钩子函数设置绑定不同，这里使用的是 <cmd> 也就是 : 模式的命令，尝试后发现不能向钩子一样使用
        --         -- f = {"<cmd>Telescope find_files<cr>", "telescope 的内置函数“查找文件”函数按键绑定"},
        --         -- g = {"<cmd>Telescope live_grep<cr>", "telescope 的内置函数“实时文本匹配”函数按键绑定"},
        --     },
        --     t = {
        --         name = "Telescope",
        --     },
        --     c = {
        --         name = "Colorizer",
        --         -- a = {"<cmd>ColorizerAttachToBuffer<cr>", "附加到当前缓冲区，并以设置（或默认设置）中指定的设置开始高亮或默认设置）开始高亮显示"},
        --         -- d = {"<cmd>ColorizerDetachFromBuffer<cr>", "停止高亮显示当前缓冲区（脱离）"},
        --         -- r = {"<cmd>ColorizerReloadAllBuffers<cr>", "使用设置中的新设置（或默认设置）重新加载所有高亮显示的缓冲区"},
        --         -- t = {"<cmd>ColorizerToggle<cr>", "切换当前缓冲区的高亮显示"},
        --     },
        --     b = {
        --         name = "Buffer",
        --         -- r = {"<cmd>ColorizerReloadAllBuffers<cr>", "使用设置中的新设置（或默认设置）重新加载所有高亮显示的缓冲区"},
        --         -- t = {"<cmd>ColorizerToggle<cr>", "切换当前缓冲区的高亮显示"},
        --     },
        -- }, { prefix = "<leader>" })
        wk.add({
            { "<leader>b", group = "Buffer" },
            { "<leader>c", group = "Colorizer" },
            { "<leader>f", group = "Files" },
            { "<leader>t", group = "Telescope" },
        })
    end
}
