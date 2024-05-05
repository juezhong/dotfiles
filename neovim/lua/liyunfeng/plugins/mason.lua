return {
    "williamboman/mason.nvim",
    -- event = "VeryLazy",
    cmd = {
        "Mason",
        "MasonInstall",
    },
    -- build = "echo 'hello' >> ~/a.txt", 
    -- build 在安装或更新插件时执行。在运行 build 之前，首先加载一个插件。
    -- 如果它是一个字符串，它将作为 shell 命令运行。
    -- 当前缀为 : 时，它是一个 Neovim 命令。您还可以指定一个列表来执行多个构建命令。
    -- 一些插件提供自己的 build.lua ，它会被 lazy 自动使用。因此无需为这些插件指定构建步骤。
    -- build = "echo 'export PATH=$PATH:~/.local/share/nvim/mason/bin/' >> ~/.zshrc",
    build = "sh ~/mason_add_path.sh",
    config = function()
        local mason = require("mason")
        mason.setup({
            ---@since 1.0.0
            -- Where Mason should put its bin location in your PATH. Can be one of:
            -- - "prepend" (default, Mason's bin location is put first in PATH)
            -- - "append" (Mason's bin location is put at the end of PATH)
            -- - "skip" (doesn't modify PATH)
            ---@type '"prepend"' | '"append"' | '"skip"'
            PATH = "prepend",
            ui = {
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗"
                },
                keymaps = {
                    ---@since 1.0.0
                    -- Keymap to expand a package
                    toggle_package_expand = "<CR>",
                    ---@since 1.0.0
                    -- Keymap to install the package under the current cursor position
                    install_package = "i",
                    ---@since 1.0.0
                    -- Keymap to reinstall/update the package under the current cursor position
                    update_package = "u",
                    ---@since 1.0.0
                    -- Keymap to check for new version for the package under the current cursor position
                    check_package_version = "c",
                    ---@since 1.0.0
                    -- Keymap to update all installed packages
                    update_all_packages = "U",
                    ---@since 1.0.0
                    -- Keymap to check which installed packages are outdated
                    check_outdated_packages = "C",
                    ---@since 1.0.0
                    -- Keymap to uninstall a package
                    uninstall_package = "X",
                    ---@since 1.0.0
                    -- Keymap to cancel a package installation
                    cancel_installation = "<C-c>",
                    ---@since 1.0.0
                    -- Keymap to apply language filter
                    apply_language_filter = "<C-f>",
                    ---@since 1.1.0
                    -- Keymap to toggle viewing package installation log
                    toggle_package_install_log = "<CR>",
                    ---@since 1.8.0
                    -- Keymap to toggle the help view
                    toggle_help = "g?",
                },
            },
        })
    end, -- end of config
}
