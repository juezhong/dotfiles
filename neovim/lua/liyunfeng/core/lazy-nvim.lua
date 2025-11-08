-- lazy.nvim initialization

-- macOS neovim data path: /Users/liyunfeng/.local/share/nvim
-- lazy.nvim check, if not exist will clone it
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

--[[
插件通过 lazy.nvim 管理，加载全部放在指定的文件 (./lua/liyunfeng/plguins/**) 下
依赖 lazy.nvim 的自动搜索和加载合并到主插件配置中的特性
--]]
-- equal require("lazy").setup("liyunfeng.plugins")
require("lazy").setup("liyunfeng/plugins")

-- Plugins setup
-- All in ./lua/liyunfeng/plugins/**.lua

