-- 2024年4月9日 09:11:07
-- 在 Arch Linux 使用 MobaXterm 连接的时候使用终端发现 Background 不能设置 前景 ctermfg guifg 不然会和背景混在一起导致无法识别
----------
-- 通过一次错误的调试发现在 Msys2(tabby同样) 环境下 nvim 是识别成了 GUI 环境
-- 因为海棠红的配色在 ctermfg 配置正确的情况下还是使用的 guifg(#f03752) 还是麦苗绿的(#55bb8a)
-- 以下正则是用来替换添加 Background 背景色的
-- ^\(vim.*\)\(Chi.*\)\( ctermfg=\)\([0-9]\{2,3\}\)\( guifg.*\)\(#[0-9a-z]\{6\}\)\(.*cterm.*\)/\1\2\3\4\5\6\7\r\1\2Background\3\4\5\6 ctermbg\=\4 guibg=\6\7
-- 有另一种方式定义颜色
-- vim.api.nvim_set_hl(0, "CustomColor", {bg = "", fg = "", bold = true, italic = true})
-- 0 表示希望所有缓冲区都使用
vim.api.nvim_set_hl(0, "CustomColor", { fg = "#310f1b", italic = true})

-- 中国色 麦苗绿
-- 85,187,138
-- #55bb8a
-- vim.cmd("highlight ChineseColorMaiMiaoGreen ctermfg=115 guifg=#55bb8a cterm=NONE gui=NONE")
vim.cmd("highlight ChineseColorMaiMiaoGreen ctermfg=115 guifg=#55bb8a cterm=italic gui=italic")
vim.cmd("highlight ChineseColorMaiMiaoGreenBackground  ctermbg=115 guibg=#55bb8a cterm=italic gui=italic")

-- 中国色 海棠红
-- 240,55,82
-- #f03752
vim.cmd("highlight ChineseColorHaiTangRed ctermfg=204 guifg=#f03752 cterm=italic gui=italic")
vim.cmd("highlight ChineseColorHaiTangRedBackground  ctermbg=204 guibg=#f03752 cterm=italic gui=italic")

-- 中国色 墨紫
-- 49,15,27
-- #310f1b
vim.cmd("highlight ChineseColorMoZi ctermfg=53 guifg=#310f1b cterm=italic gui=italic")
vim.cmd("highlight ChineseColorMoZiBackground  ctermbg=53 guibg=#310f1b cterm=italic gui=italic")

-- 中国色 品红
-- 239,52,115
-- #ef3473
vim.cmd("highlight ChineseColorPinHong ctermfg=204 guifg=#ef3473 cterm=italic gui=italic")
vim.cmd("highlight ChineseColorPinHongBackground  ctermbg=204 guibg=#ef3473 cterm=italic gui=italic")

-- 中国色 品蓝
-- 43,115,175
-- #2b73af
vim.cmd("highlight ChineseColorPinLan ctermfg=67 guifg=#2b73af cterm=italic gui=italic")
vim.cmd("highlight ChineseColorPinLanBackground  ctermbg=67 guibg=#2b73af cterm=italic gui=italic")

-- 中国色 山梗紫
-- 97,100,159
-- #61649f
vim.cmd("highlight ChineseColorShanGengZi ctermfg=103 guifg=#61649f cterm=italic gui=italic")
vim.cmd("highlight ChineseColorShanGengZiBackground  ctermbg=103 guibg=#61649f cterm=italic gui=italic")

-- 中国色 浪花绿
-- 146,179,165
-- #92b3a5
vim.cmd("highlight ChineseColorLangHuaGreen ctermfg=151 guifg=#92b3a5 cterm=italic gui=italic")
vim.cmd("highlight ChineseColorLangHuaGreenBackground  ctermbg=151 guibg=#92b3a5 cterm=italic gui=italic")
