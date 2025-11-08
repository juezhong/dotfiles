-- TODO: adapt VSCode neovim plugin, see https://marketplace.visualstudio.com/items?itemName=asvetliakov.vscode-neovim&ssr=false#overview
if vim.g.vscode then
    -- VSCode extension
    require("liyunfeng.vscode.options")
    require("liyunfeng.vscode.keymaps")
    require("liyunfeng.vscode.lazynvim")
    -- vim.cmd("highlight ChineseColorMaiMiaoGreen ctermfg=115 guifg=#55bb8a cterm=NONE gui=NONE")
    require("liyunfeng.UserColors.ChineseColors")
else
    -- ordinary Neovim
end
