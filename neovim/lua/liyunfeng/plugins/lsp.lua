-- 关于 neovim lsp 的相关配置

-- from init.lua
-- TODO: Remove this later
-- 手动使用 lsp 的过程
-- 可以使用 nvim-lspconfig 插件替代，插件的作用是以下的作用和一些自动的设置
-- nvim-lspconfig 是一个用于管理和配置 Language Server Protocol (LSP) 客户端的工具。
-- 简化了在 Neovim 中设置和使用各种语言服务器的过程。它提供了大量的内置配置项，
-- 针对不同的编程语言和对应的 LSP 服务器，用户可以通过简单的 API 快速启用和配置相应的 LSP 功能，而无需手动处理复杂的底层细节。
-- vim.api.nvim_create_autocmd("BufEnter", {
--     -- table 中可以设置其他的元数据，但回调函数就是需要执行的动作
--     callback = function()
--         -- 如果 lsp 客户端的检查启动太快将没有作用，因为在加载 buffer 之前就启动完了，所以要延后到 buffer 加载完成
--         -- 触发 BufEnter event 事件之后再加载 lsp 的客户端进行代码检查，这需要使用到 autocmd 相关的命令
--         vim.lsp.start({
--             name = "manual-clangd",
--             cmd = {"D:\\Software\\Msys2\\ucrt64\\bin\\clangd.exe"},
--             -- 使用 vim 函数获取当前文件的路径，相当于 pwd
--             root_dir = vim.fn.getcwd(),
--         })
--     end,
-- })

return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "hrsh7th/cmp-nvim-lsp",
    },
    -- event = "InsertEnter",
    -- 设置特定的 filetype 才启动
    ft = {
        "c",
        "lua",
        "cmake",
    },
    event = "InsertLeave",
    config = function()
        local capabilities = require("cmp_nvim_lsp").default_capabilities()
        local servers = { "clangd", "lua_ls" }

        for _, server in ipairs(servers) do
            vim.lsp.config(server, {
                capabilities = capabilities,
            })
            vim.lsp.enable(server)
        end
    end,
}
