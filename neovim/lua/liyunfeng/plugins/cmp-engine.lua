-- 补全引擎，没有任何补全的功能，需要通过其他插件提供 source 来获取补全
return {
    "hrsh7th/nvim-cmp",
    dependencies = {
        -- "hrsh7th/cmp-emoji",
        -- "hrsh7th/cmp-cmdline",
        -- 虽然可以通过依赖的方式安装，但还是分开单独的插件配置
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-nvim-lsp",
        "saadparwaiz1/cmp_luasnip",
    },
    -- lazy = true,
    -- event = "InsertEnter",
    event = {
        "InsertEnter",
        "CmdlineEnter",
    },
    config = function()
        local cmp = require("cmp")
        local compare = cmp.config.compare
        local luasnip = require("luasnip")
        cmp.setup({
            -- -- 如果你想要在启动补全时自动选择第一个项，可以设置 preselect 选项
            -- preselect = cmp.PreselectMode.Item,
            experimental = {
                -- ghost_text = true, -- 启用幽灵文本
                ghost_text = {
                    -- 设置颜色
                    -- 这个为自定义的颜色
                    -- hl_group = 'ChineseColorMaiMiaoGreen',
                    hl_group = 'ChineseColorHaiTangRed',
                    -- hl_group = 'ChineseColorPinLan',
                },
            },
            snippet = {
                expand = function(args)
                    -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
                    require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                    -- require'snippy'.expand_snippet(args.body) -- For `snippy` users.
                    -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
                end,
            },
            window = {
                -- 可以通过八组字符来定义边框
                completion = cmp.config.window.bordered({
                    border = "double",
                    -- border = "none",
                    -- winhighlight = "Normal:White,FloatBorder:Pmenu,CursorLine:Blue,Search:None",
                    -- winhighlight = "Normal:ChineseColorPinLan,FloatBorder:ChineseColorMaiMiaoGreen,CursorLine:ChineseColorPinHong,Search:None",
                    winhighlight = "Normal:ChineseColorMoZi,FloatBorder:ChineseColorMaiMiaoGreen,CursorLine:ChineseColorPinHong,Search:None",
                    -- winhighlight = "Normal:ChineseColorMoZi,FloatBorder:ChineseColorMaiMiaoGreen,CursorLine:ChineseColorHaiTangRed,Search:None",
                    side_padding = 1,
                }),
                documentation = cmp.config.window.bordered(),
            },
            mapping = cmp.mapping.preset.insert({
                -- 向下移动到下一个补全项
                ['<C-n>'] = cmp.mapping.select_next_item(),
                -- 向上移动到上一个补全项
                ['<C-p>'] = cmp.mapping.select_prev_item(),
                -- 使用 Ctrl + n 向下移动文档预览浮窗
                ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                -- 使用 Ctrl + p 向上移动文档预览浮窗
                ["<C-f>"] = cmp.mapping.scroll_docs(4),
                -- 中止当前的补全操作
                ['<C-g>'] = cmp.mapping.abort(),
                -- 使用回车键确认补全
                -- ["<CR>"] = cmp.mapping.confirm({ select = true }),
                ["<CR>"] = cmp.mapping({
                    i = function(fallback)
                        if cmp.visible() and cmp.get_active_entry() then
                            cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
                        else
                            fallback()
                        end
                    end,
                    s = cmp.mapping.confirm({ select = true }),
                    c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
                }),
                -- -- 使用 TAB 键展开代码片段
                -- ['<Tab>'] = cmp.mapping(function(fallback)
                --     if cmp.visible() then
                --         cmp.select_next_item()
                --     elseif luasnip.expand_or_jumpable() then
                --         luasnip.expand_or_jump()
                --     else
                --         fallback() -- 如果没有可用的补全项，执行默认的 TAB 行为
                --     end
                -- end),
                -- Intellij-like
                ["<Tab>"] = cmp.mapping(function(fallback)
                    -- This little snippet will confirm with tab, and if no entry is selected, will confirm the first item
                    if cmp.visible() then
                        local entry = cmp.get_selected_entry()
                        if not entry then
                            cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                        end
                        cmp.confirm()
                    elseif luasnip.expand_or_jumpable() then
                        luasnip.expand_or_jump()
                    else
                        fallback() -- 如果没有可用的补全项，执行默认的 TAB 行为
                    end
                end, { "i", "s", "c", }),

                -- 使用 Shift+TAB 回到上一个位置
                ['<S-Tab>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    elseif luasnip.jumpable(-1) then -- 尝试向左跳转
                        luasnip.jump(-1) -- 实际执行跳转
                    else
                        fallback() -- 如果不能跳转，执行默认的 Shift+TAB 行为
                    end
                end, { "i", "s" }),
                -- 填充当前补全项，而不是确定
                ['<C-e>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        return cmp.complete_common_string()
                    end
                    fallback()
                end, { 'i', 'c' }),
            }),
            -- 使用 cmp.config.sources 设置分组的全局 Global 补全源
            sources = cmp.config.sources(
                -- group 1 lsp
                -- {
                --     {
                --         name = "nvim_lsp",
                --         -- option = {
                --         -- },
                --     },
                --     {
                --         name = "luasnip",
                --         option = {
                --             show_autosnippets = false
                --         },
                --     },
                --     priority = 1000,
                -- },
                --[[ 
                使用 group 1-1 和 group 1-2 的方式和上面直接使用 group 1 的区别是
                使用不同分组能将补全的选项分开，只要有 1-1 的内容就不会显示 1-2 的内容
                仅当 1-1 没有内容时，1-2 才会显示
                ]]
                -- group 1-1
                {
                    -- keyword_lengh 控制补全触发的长度，唯一不足是触发后打字就会消失，必须3个字符
                    -- { name = "nvim_lsp", keyword_lengh = 3 },
                    {
                        name = "nvim_lsp",
                        -- 过滤 lsp 提供的 snippet
                        entry_filter = function (entry, ctx)
                            -- LOG.debug(entry:get_kind())
                            if entry:get_kind() == 15 then
                                return false
                            end
                            return true
                        end
                    },
                },
                -- group 1-2
                {
                    { name = "luasnip" },
                },
                -- group 2 general
                {
                    {
                        name = "buffer",
                        option = {
                            -- 发现默认是 1 
                            -- keyword_lengh = 5,
                            -- 使用所有 buffer 的内容补全
                            get_bufnrs = function()
                                return vim.api.nvim_list_bufs()
                            end,
                        },
                        -- priority = 750,
                    },
                    -- { name = "cmp other sources" },
                    {
                        name = "path",
                        option = {
                            -- 指定完成菜单中的目录名称是否应包含尾部斜杠。
                            label_trailing_slash = true
                            -- label_trailing_slash = false
                        },
                        -- priority = 500,
                    },
                }
                -- group 3 other
                -- {},
            ), -- end config.sources
            sorting = {
                comparators = {
                    compare.exact,
                    compare.locality,
                },
            },
        }) -- cmp.setup end

        -- cmp.setup.cmdline 是专门用于配置命令行模式下补全行为的函数。
        -- 当你在 Neovim 中输入 / 或 : 进入查找模式或命令模式时，
        -- 这个函数允许你为这些特定的模式设置补全源和键位映射。
        -- 这使得你可以为不同的命令行模式提供定制化的补全体验。
        -- `/` 查找模式下的补全配置
        -- cmp.setup.cmdline({ "/", "?" }, {
        cmp.setup.cmdline("/", {
            -- mapping = cmp.mapping.preset.cmdline({
            --     -- 向下移动到下一个补全项
            --     ['<C-n>'] = cmp.mapping.select_next_item(),
            --     -- 向上移动到上一个补全项
            --     ['<C-p>'] = cmp.mapping.select_prev_item(),
            --     -- 使用 Ctrl + n 向下移动文档预览浮窗
            --     ["<C-b>"] = cmp.mapping.scroll_docs(-4),
            --     -- 使用 Ctrl + p 向上移动文档预览浮窗
            --     ["<C-f>"] = cmp.mapping.scroll_docs(4),
            --     -- 中止当前的补全操作
            --     ['<C-g>'] = cmp.mapping.abort(),
            -- }),
            mapping = cmp.mapping.preset.cmdline(),
            -- 这行设置了命令行模式下的默认键位映射。
            -- cmp.mapping.preset.cmdline() 提供了一系列默认的键位映射，例如使用 Tab 键在补全选项之间跳转，使用 Enter 确认补全等。
            sources = {
                -- 使用了 flash.nvim ，可以取消搜索的 buffer 补全了
                -- { name = "buffer" } -- 从当前缓冲区获取补全
            }
        })

        -- `:` 命令模式下的补全配置
        cmp.setup.cmdline(":", {
            mapping = cmp.mapping.preset.cmdline({
                -- 中止当前的补全操作
                -- ['<C-g>'] = cmp.mapping.abort(),
                -- 以上快捷键不生效，只能使用 C-e 终止补全
            }),
            sources = cmp.config.sources(
                -- group 1
                {
                    { name = "path" }, -- 从文件路径获取补全
                    -- { name = "buffer" }
                },
                -- group 2
                {
                    {
                        name = "cmdline",
                        option = {
                            ignore_cmds = { "Man", "!" } -- 忽略某些命令不显示补全
                        }
                    },
                }
            ) -- end config.sources
        })

        -- lsp 相关的补全源设置
        -- 给 nvim-cmp 提供lsp的关键字补全
        -- move to ./lsp.lua
    end,
}
