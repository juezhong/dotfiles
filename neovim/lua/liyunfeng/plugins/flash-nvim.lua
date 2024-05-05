return {
    -- hop.nvim 可以支持中文的跳转，其他的支持不太好
    -- flash 是通过 prefix 然后输入搜索字符来进行光标的跳转的
    -- Hop 类似 "EasyMotion" 的方式，通过 prefix 然后选择每个单词上显示的 label 进行光标的跳转
    -- flash 可以结合 operator 来使用比如 y/*** 可以快速从当前位置然后复制到选择的单词，其他的 d c 同理
    "folke/flash.nvim",
    event = "VeryLazy",
    -- opts = {
    -- },
    -- lazy load
    keys = {
        -- 手动创建键盘映射时，可以使用 function() require("flash").jump() end 这样的 lua 函数作为 rhs，
        -- 或者使用 <cmd>lua require("flash").jump()<cr> 这样的字符串。不要使用 :lua ，因为这会破坏 dot-repeat
        { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
        { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
        { "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
        { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
        { "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
        -- { ".",     mode = { "n", "x", "o" }, function() require("flash").jump({
        --             pattern = ".",     -- initialize pattern with any char
        --             search = {
        --                 mode = function(pattern)
        --                     -- remove leading dot
        --                     if pattern:sub(1, 1) == "." then
        --                         pattern = pattern:sub(2)
        --                     end
        --                     -- return word pattern and proper skip pattern
        --                     return ([[\<%s\w*\>]]):format(pattern), ([[\<%s]]):format(pattern)
        --                 end,
        --             },
        --             -- select the range
        --             jump = { pos = "range" },
        --         })
        --     end,
        --     desc = "Select any word"},
        -- 以上选择任意 word 的功能也使用 Hop.nvim 替代
        -- 想要使用 2 个字符跳转的功能，但支持不太好，使用 Hop.nvim 插件替代
        -- { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
    },
    config = function()
--[[
        -- set a link
        vim.cmd("highlight link FlashMatch ChineseColorPinHong")
        -- remove a link
        vim.cmd("highlight link FlashMatch NONE")
]]
        -- 重新设置 Flash 搜索时高亮的颜色
        -- Group             Default      Description
        -- FlashBackdrop     Comment      backdrop
        -- 进入搜索时候的所有等待被输入搜索的字体背景
        -- FlashBackdrop 不设置默认是 comment 的灰色
        -- FlashMatch        Search       search matches
        vim.cmd("highlight link FlashMatch ChineseColorPinHong") -- 所有搜索的匹配项的背景
        -- FlashCurrent      IncSearch    current match
        vim.cmd("highlight link FlashCurrent ChineseColorLangHuaGreenBackground") -- 搜索时光标所在的匹配项位置背景
        -- FlashLabel        Substitute   jump label
        vim.cmd("highlight link FlashLabel ChineseColorPinLanBackground") -- 搜索时匹配的 label 的背景，如果设置了彩虹色则无效 line 131
        -- 搜索时候的颜色仅需要配置以上四种即可
        -- FlashPrompt       MsgArea      prompt
        -- FlashPromptIcon   Special      prompt icon
        -- FlashCursor       Cursor       cursor

        local flash = require("flash")
        -- 放在 opts 字段中的设置根本没用，也许是抄错了，不适用于 lazy.nvim，lazy 更改默认的属性可能是用别的字段
        flash.setup({
            -- labels = "abcdefghijklmnopqrstuvwxyz",
            labels = "asdfghjklqwertyuiopzxcvbnm",
            search = {
                -- search/jump in all windows
                multi_window = true,
                -- Excluded filetypes and custom window filters
                ---@type (string|fun(win:window))[]
                exclude = {
                    "notify",
                    "cmp_menu",
                    "noice",
                    "flash_prompt",
                    function(win)
                        -- exclude non-focusable windows
                        return not vim.api.nvim_win_get_config(win).focusable
                    end,
                },
            },
            jump = {
                -- save location in the jumplist
                jumplist = true,
                -- jump position
                pos = "start", ---@type "start" | "end" | "range"
                -- add pattern to search history
                history = false,
                -- add pattern to search register
                register = false,
                -- clear highlight after jump
                nohlsearch = false,
                -- automatically jump when there is only one match
                autojump = false,
                -- You can force inclusive/exclusive jumps by setting the
                -- `inclusive` option. By default it will be automatically
                -- set based on the mode.
                inclusive = nil, ---@type boolean?
                -- jump position offset. Not used for range jumps.
                -- 0: default
                -- 1: when pos == "end" and pos < current position
                offset = nil, ---@type number
            },
            label = {
                -- allow uppercase labels
                uppercase = false,
                -- add any labels with the correct case here, that you want to exclude
                exclude = "",
                -- add a label for the first match in the current window.
                -- you can always jump to the first match with `<CR>`
                current = true,
                -- show the label after the match
                -- after = true, ---@type boolean|number[]
                after = true, ---@type boolean|number[]
                -- show the label before the match
                before = false, ---@type boolean|number[]
                -- position of the label extmark
                style = "overlay", ---@type "eol" | "overlay" | "right_align" | "inline"
                -- flash tries to re-use labels that were already assigned to a position,
                -- when typing more characters. By default only lower-case labels are re-used.
                reuse = "lowercase", ---@type "lowercase" | "all" | "none"
                -- for the current window, label targets closer to the cursor first
                distance = true,
                -- minimum pattern length to show labels
                -- Ignored for custom labelers.
                min_pattern_length = 0,
                -- Enable this to use rainbow colors to highlight labels
                -- Can be useful for visualizing Treesitter ranges.
                rainbow = {
                    -- enabled = true,
                    -- number between 1 and 9
                    -- shade = 5,
                },
                -- With `format`, you can change how the label is rendered.
                -- Should return a list of `[text, highlight]` tuples.
                ---@class Flash.Format
                ---@field state Flash.State
                ---@field match Flash.Match
                ---@field hl_group string
                ---@field after boolean
                ---@type fun(opts:Flash.Format): string[][]
                -- 控制不同的搜索类型对应不同的高亮组，不使用的话就是默认
                format = function(opts)
                    -- lable 对应类型，hl_group 对应高亮组
                    return { { opts.match.label, opts.hl_group } }
                end,
            },
            highlight = {
                -- show a backdrop with hl FlashBackdrop
                backdrop = true,
                -- Highlight the search matches
                -- matches = false,
                matches = true,
                -- extmark priority
                priority = 5000,
                groups = {
                    -- 所有搜索的匹配项的背景
                    -- match = "FlashMatch",
                    -- match = "ChineseColorPinHong",
                    -- 搜索时光标所在的匹配项位置背景
                    -- current = "FlashCurrent",
                    -- current = "ChineseColorLangHuaGreenBackground",
                    -- 进入搜索时候的所有等待被输入搜索的字体背景
                    -- backdrop = "FlashBackdrop",
                    -- 搜索时匹配的 label 的背景，如果设置了彩虹色则无效
                    -- label = "FlashLabel",
                    -- label = "ChineseColorPinLanBackground",
                },
            },
            -- Set config to a function to dynamically change the config
            -- config = nil, ---@type fun(opts:Flash.Config)|nil
            -- You can override the default options for a specific mode.
            -- Use it with `require("flash").jump({mode = "forward"})`
            ---@type table<string, Flash.Config>
            modes = {
                -- options used when flash is activated through
                -- a regular search with `/` or `?`
                search = {
                    -- when `true`, flash will be activated during regular search by default.
                    -- You can always toggle when searching with `require("flash").toggle()`
                    -- 禁用 / 和 ? 下使用 Flash
                    enabled = false,
                    highlight = { backdrop = false },
                    jump = { history = true, register = true, nohlsearch = true },
                    search = {
                        -- `forward` will be automatically set to the search direction
                        -- `mode` is always set to `search`
                        -- `incremental` is set to `true` when `incsearch` is enabled
                    },
                },
                -- options used when flash is activated through
                -- `f`, `F`, `t`, `T`, `;` and `,` motions
                char = {
                    enabled = false,
                },
                -- options used for treesitter selections
                -- `require("flash").treesitter()`
                treesitter = {
                },
                treesitter_search = {
                },
                -- options used for remote flash
                remote = {
                    remote_op = { restore = true, motion = true },
                },
            },
            -- options for the floating window that shows the prompt,
            -- for regular jumps
            prompt = {
                enabled = true,
                prefix = { { "⚡", "FlashPromptIcon" } },
                win_config = {
                },
            },
            -- options for remote operator pending mode
            remote_op = {
            },
        }) -- end flash.setup()
    end
}
