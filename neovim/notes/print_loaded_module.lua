-- 遍历 package.loaded 表，打印已加载模块及其路径

for moduleName, modulePath in ipairs(package.loaded) do
    -- print(moduleName .. ": " .. modulePath)
    vim.api.nvim_out_write(moduleName .. ": " .. modulePath .. "\n")
end

