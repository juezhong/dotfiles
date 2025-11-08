-- must installed lazy-nvim plugin
-- vscode plugin config
-- VS Code 环境
-- 仅加载 VS Code 兼容的插件

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
vim.opt.rtp:prepend(lazypath)
-- require('lazy').setup({"liyunfeng.vscode.plugins"})

-- require("lazy").setup({"liyunfeng.vscode.plugins"})
require("lazy").setup({
	-- { import = "user.plugins_notvscode", cond = (function() return not vim.g.vscode end) },
	-- { import = "user.plugins_always",    cond = true },
	-- { import = "user.plugins_vscode",    cond = (function() return vim.g.vscode end) },
	-- 只导入 VSCode/Cursor 兼容的插件
    { import = "liyunfeng.vscode.plugins", cond = true },
})
