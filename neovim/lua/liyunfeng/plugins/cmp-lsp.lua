return {
    "hrsh7th/cmp-nvim-lsp",
    lazy = true,
    config = function()
        -- 给 nvim-cmp 提供lsp的关键字补全（应该是功能增强）
        -- 添加 nvim-cmp 支持的其他功能
        local capabilities = require('cmp_nvim_lsp').default_capabilities()
        local lspconfig = require("lspconfig")
        -- 使用 nvim-cmp 提供的额外补全功能启用某些语言服务器
        local servers = { "clangd", "lua_ls" }
        for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup {
            -- on_attach = my_custom_on_attach,
            capabilities = capabilities,
        }
        end

        -- lspconfig["lua_ls"].setup({
        --     capabilities = capabilities
        -- })
        -- lspconfig.clangd.setup({
        -- lspconfig["clangd"].setup({
        --     capabilities = capabilities
        -- })
        -- lspconfig["cmake"].setup({
        --     capabilities = capabilities
        -- })

    end
}
