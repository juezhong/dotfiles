return {
  "xiyaowong/transparent.nvim",
  lazy = false,
  config = function()
    require("transparent").setup({
      -- 额外清理浮窗和常见插件窗口背景
      extra_groups = {
        "NormalFloat",
        "FloatBorder",
        "NvimTreeNormal",
        "NeoTreeNormal",
        "TelescopeNormal",
        "TelescopeBorder",
        "WhichKeyFloat",
        "MasonNormal",
        "LazyNormal",
      },
    })

    -- 默认启用透明背景
    vim.cmd("TransparentEnable")
  end,
}
