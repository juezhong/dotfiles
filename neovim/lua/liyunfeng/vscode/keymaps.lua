-- vim keymap
--[[
-- General Keymaps
-- 通用的按键设置
--]]

-- set leader key
vim.g.mapleader = ","
-- 敲三次 leader 键进入 cmdline 输入命令
vim.keymap.set("n", "<leader><leader><leader>", ":")

--[[ Normal mode ]]
vim.keymap.set("n", "J", "5j")
vim.keymap.set("n", "K", "5k")
vim.keymap.set("n", "H", "0")
vim.keymap.set("n", "L", "$")
vim.keymap.set("n", "dH", "d0")
vim.keymap.set("n", "dL", "d$")
vim.keymap.set("v", "J", "5j")
vim.keymap.set("v", "K", "5k")

-- normal 模式下 <leader>+n+h 取消搜索高亮，也就是执行后面的命令
vim.keymap.set("n", "<leader>nh", ":nohl<cr>")
-- normal 模式下 空格+n+h 取消搜索高亮，也就是执行后面的命令
vim.keymap.set("n", "<backspace>", "<cmd>nohl<cr>")
vim.keymap.set("n", "<leader>+", "<C-a>") -- 对数字进行递增递减
vim.keymap.set("n", "<leader>-", "<C-x>")

vim.keymap.set("n", "<leader>wv", "<C-w>v") -- 垂直 split window vertically 分割窗口
vim.keymap.set("n", "<leader>wh", "<C-w>s") -- 水平 split window horizontally 分割窗口
vim.keymap.set("n", "<leader>we", "<C-w>=") -- 调整使分割窗口宽度相等
vim.keymap.set("n", "<leader>wx", ":close<CR>") -- 关闭当前分割的窗口
vim.keymap.set("n", "<leader>wh", "<C-w>h") -- 窗口选择
vim.keymap.set("n", "<leader>wj", "<C-w>j")
vim.keymap.set("n", "<leader>wk", "<C-w>k")
vim.keymap.set("n", "<leader>wl", "<C-w>l")

vim.keymap.set("n", "<leader>to", ":tabnew<CR>")  -- 打开一个新的标签 tab
vim.keymap.set("n", "<leader>tc", ":tabclose<CR>")    -- 关闭当前标签
vim.keymap.set("n", "<leader>tn", ":tabn<CR>")        -- 转到下一个标签
vim.keymap.set("n", "<leader>tp", ":tabp<CR>")        -- 转到上一个标签

vim.keymap.set("n", "<leader>bo", ":badd ") -- 打开一个新的Buffer
-- vim.keymap.set("n", "<leader>bc", ":bdelete") -- 关闭当前Buffer
-- vim.keymap.set("n", "<leader>bn", ":bnext<CR>") -- 转到下一个Buffer
-- vim.keymap.set("n", "<leader>bp", ":bNext<CR>") -- 转到上一个Buffer
-- vim.keymap.set("n", "<leader>bj", ":LualineBuffersJump ") -- 跳转到指定Buffer（弃用，使用 telescope）

--[[ Insert mode ]]
-- vim.keymap.set("i", "jk", "<esc>")
-- vim.keymap.set("i", "jj", "<esc>")
-- vim.keymap.set("i", "kk", "<esc>")
-- 需要在 vscode 的配置中添加另外的设置

--[[ Visual mode ]]
-- 为了粘贴之后而不覆盖剪切板的内容
-- vim.keymap.set("v", "p", '"_dP')
vim.keymap.set("v", "p", "P")
