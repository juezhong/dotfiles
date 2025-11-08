-- 获取已加载模块的所有方法
function getModuleMethods(module)
    local methods = {}
    for key, value in pairs(module) do
        if type(value) == "function" then
                table.insert(methods, key)
        end
    end
    return methods
end

-- 替换 "your_module" 为你已加载的模块
-- local yourModule = require("your_module")
local module = require("bufferline")

-- 获取模块的所有方法
local methods = getModuleMethods(module)

-- 打印方法列表
-- for _, method in ipairs(methods) do
--     print(method)
-- end

-- 格式化输出
local output = {}
for _, method in ipairs(methods) do
    table.insert(output, method)
end

-- 使用 Neovim 的美化输出格式打印方法列表
-- vim.api.nvim_out_write(vim.inspect(output) .. "\n")

-- 将table中的内容连接成一个字符串
local content = table.concat(output, "\n")

-- 定义文件路径
local filePath = "./methods.txt"  -- 替换为你想要保存文件的路径

-- 打开文件并写入内容
local file = io.open(filePath, "w")
file:write(content)
file:close()

-- 在Neovim中打开文件
vim.cmd("edit " .. filePath)

