--[[ 自动命令是响应某些命令而自动执行的命令事件，例如正在读取或写入文件或缓冲区更改。
通过例如，使用自动命令，您可以训练 Vim 编辑压缩文件。
这是在 gzip 插件中使用的。
自动命令非常强大。小心使用它们，它们会帮助你避免键入许多命令。使用不小心会造成很多麻烦。

自动命令是自动执行的 Vim 命令或 Lua 函数每当触发一个或多个事件时执行，
例如，当文件被触发读取或写入，或者创建窗口时。 ]]

-- 有两个重要的参数
-- {event} 监听触发的事件
-- {opts} 一个表，其中的键控制触发事件时应该发生的情况。
-- opts 是由
-- - pattern 指定匹配的模式 * 表示所有文件格式都匹配，区别于 *.c 和 *.h
-- - command vim的命令
-- - callback lua的函数
-- command 和 callback 必须两个选一个
-- 三个选项组成的 table
-- 您必须指定 command 和 callback 之一且仅之一。
-- 如果 pattern 是省略，默认为 pattern = '*'

--[[
vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
    pattern = {"*.c", "*.h"},
    command = "echo 'Entering a C or C++ file'",
})
-- Same autocommand written with a Lua function instead
vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
    pattern = {"*.c", "*.h"},
    callback = function() print("Entering a C or C++ file") end,
})
-- User event triggered by MyPlugin
vim.api.nvim_create_autocmd("User", {
    pattern = "MyPlugin",
    callback = function() print("My Plugin Works!") end,
})
]]

-- 注意顺序问题，后面的会覆盖前面的所以能被单独文件类型检测到
--[[ vim.api.nvim_create_autocmd("BufEnter", {
    -- pattern = {},
    -- pattern = "*",
    callback = function()
        print("enter file.")
    end
})

vim.api.nvim_create_autocmd("BufEnter", {
    pattern = {"*.c", "*.txt"},
    callback = function()
        print("enter c or txt file.")
    end
}) ]]

-- save cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
    pattern = "*",
    callback = function()
        if vim.fn.line("'\"") > 0 and vim.fn.line("'\"") <= vim.fn.line("$") then
            vim.fn.setpos(".", vim.fn.getpos("'\""))
            vim.cmd("silent! foldopen")
        end
    end,
})

-- Disable newline comment
vim.api.nvim_create_autocmd({ "BufEnter" }, {
    pattern = "*",
    callback = function()
        vim.opt.formatoptions = vim.opt.formatoptions - { "c", "r", "o" }
    end,
})

-- 在 copy 后高亮复制的区域
vim.api.nvim_create_autocmd({ "TextYankPost" }, {
    pattern = { "*" },
    callback = function()
        vim.highlight.on_yank({ timeout = 300 })
    end
})

-- 在保存文件之前自动格式化
-- vim.api.nvim_create_autocmd("BufWritePre", {
--     -- buffer = buffer,
--     callback = function()
--         vim.lsp.buf.format( {async = false} )
--     end
-- })

vim.api.nvim_create_autocmd("BufEnter", {
    pattern = { "*.c", "*.h", "*.cpp", "*.cc", "*.hpp" },
    callback = function()
        -- 为了和 clangd lsp 的自动格式化做匹配
        -- TODO: 可以修改会 4 个空格
        vim.opt.tabstop = 4
        -- >> 和 << 的缩进数量
        vim.opt.softtabstop = 4
        vim.opt.shiftwidth = 4
    end
})
