return {
    -- 警告：如果您使用 LuaSnip，请确保使用 require("luasnip.loaders.from_vscode").lazy_load()
    -- 并将 friendly-snippets 添加为 LuaSnip 的依赖项，否则可能无法检测到代码片段。
    -- 如果您不使用 lazy_load() ，您可能会注意到启动时间较慢
    "rafamadriz/friendly-snippets",
    lazy = true,
    config = function()
        require("luasnip.loaders.from_vscode").lazy_load()
    end
}
