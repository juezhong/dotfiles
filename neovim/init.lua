if vim.loader then
    vim.loader.enable()
end
-- 使用 require 加载文件模块的方式不用写完整的相对路径
-- 因为默认使用 lua 作为 root 目录
-- 完整路径 lua/liyunfeng/core/options
require("liyunfeng/core/options")
require("liyunfeng/core/keymaps")
require("liyunfeng.core.autocommands")
require("liyunfeng.core.usercommands")

-- vim.cmd("highlight ChineseColorMaiMiaoGreen ctermfg=115 guifg=#55bb8a cterm=NONE gui=NONE")
-- 使用 colors/**.vim 的方式，只能使用以下的方式手动加载
-- vim.cmd("colorscheme ChineseColorMaiMiaoGreen")
require("liyunfeng.UserColors.ChineseColors")

-- 加载插件管理器 lazy.nvim
require("liyunfeng.core.lazy-nvim")
