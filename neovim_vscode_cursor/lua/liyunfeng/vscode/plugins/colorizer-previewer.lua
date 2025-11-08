return {
    "norcalli/nvim-colorizer.lua",
    lazy = "VeryLazy",
    -- cmd = {
    --     "<cmd>ColorizerAttachToBuffer<cr>",
    --     "<cmd>ColorizerDetachFromBuffer<cr>",
    --     "<cmd>ColorizerReloadAllBuffers<cr>",
    --     "<cmd>ColorizerToggle<cr>",
    -- },
    keys = {
        { "<leader>ca", "<cmd>ColorizerAttachToBuffer<cr>", desc = "附加到当前缓冲区，并以设置（或默认设置）中指定的设置开始高亮或默认设置）开始高亮显示" },
        { "<leader>cd", "<cmd>ColorizerDetachFromBuffer<cr>", desc = "停止高亮显示当前缓冲区（脱离）" },
        { "<leader>cr", "<cmd>ColorizerReloadAllBuffers<cr>", desc = "使用设置中的新设置（或默认设置）重新加载所有高亮显示的缓冲区" },
        { "<leader>ct", "<cmd>ColorizerToggle<cr>", desc = "切换当前缓冲区的高亮显示" },
    },
    config = function()
    end
}
