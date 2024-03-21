return {
    -- flash 是通过 prefix 然后输入搜索字符来进行光标的跳转的
    -- Hop 类似 "EasyMotion" 的方式，通过 prefix 然后选择每个单词上显示的 label 进行光标的跳转
    -- hop.nvim 可以支持中文的跳转，其他的支持不太好，剩下的功能也和 flash.nvim 类似
    "hadronized/hop.nvim",
    lazy = "VeryLazy",
    keys = {
        -- { ".", mode = { "n", "x", "o" }, function() require("hop").hint_words({ multi_windows = true, uppercase_labels = false}) end, desc = "Flash" },
        { ".", mode = { "n", "x", "o" }, function() require("hop").hint_words({ multi_windows = true }) end, desc = "Jump Any Word" },
    },
    config = function()
        local hop = require("hop")
        hop.setup()
    end,
}
