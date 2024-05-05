-- vim options setup
-- 空格替代 TAB
vim.opt.expandtab = true
-- TAB 缩进数量，使用空格替代
vim.opt.tabstop = 4
-- >> 和 << 的缩进数量
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
-- 设置自动缩进
vim.opt.autoindent = true
-- 显示行号
vim.opt.number = true
-- 使用相对行号
vim.opt.relativenumber = true
-- 高亮所在行
vim.opt.cursorline = true
-- appearance 外观
-- 保证配色方案可以使用
-- 不使用终端的配色
-- true color 真彩色终端配色可用
-- 背景高亮颜色 dark or light default dark
-- 侧边列显示符号
vim.opt.termguicolors = true
-- vim.opt.background = "light"
vim.opt.background = "dark"
vim.opt.signcolumn = "yes"
-- 光标样式
vim.opt.guicursor = "a:blinkon100"
-- 右侧参考线
vim.opt.colorcolumn = "160"
-- 搜索大小写不敏感，除非包含大写
vim.opt.ignorecase = true
vim.opt.smartcase = true
-- 命令模式行高
vim.opt.cmdheight = 1
-- 补全增强
vim.opt.wildmenu = true
-- 不要将信息传递给 "正在完成的菜单"。
vim.o.shortmess = vim.o.shortmess .. 'c'
-- 补全最多显示10行
-- vim.o.pumheight = 10
-- 自动加载外部修改
vim.opt.autoread = true
-- 禁止折行
vim.opt.wrap = false
-- 鼠标支持
-- vim.opt.mouse = "nvi"
-- 禁止创建备份文件
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
-- 不可见字符的显示，这里只把空格显示为一个点
-- vim.opt.list = false
-- vim.opt.listchars = "space:·,tab:>-"
-- 设置编码格式
-- vim.cmd("set encoding=utf-8")
vim.opt.encoding = "utf-8"
-- split windows
-- 拆分后新窗口位于当前窗口的右侧
-- 拆分后的新窗口位于当前窗口下方
vim.opt.splitright = true
vim.opt.splitbelow = true
-- 使用系统剪切板
vim.opt.clipboard = "unnamedplus"
-- 让光标在 visual block 模式突破行最后的限制
vim.opt.virtualedit = "block"
-- 打开某些命令的底部小窗口预览
vim.opt.inccommand = "split"
