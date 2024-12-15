local wezterm = require("wezterm")
-- Import our new module (put this near the top of your wezterm.lua)


local config = {
    front_end = "WebGpu",
    -- front_end = "OpenGL",
    tab_bar_at_bottom = true,
    hide_tab_bar_if_only_one_tab = true,
    font_dirs = { '/Users/liyunfeng/Library/Fonts'},
    -- font = wezterm.font('JetBrainsMono NFM', { weight = 'Medium' }),
    -- font = wezterm.font('JetBrainsMono NFM', { weight = 'Regular', italic = true })
    font_size = 14.0,
    font = wezterm.font('MesloLGS Nerd Font Mono'),
    window_background_opacity = 0.625,
    macos_window_background_blur = 45,
    -- window_padding = {
    --     left = 10,
    --     right = 1,
    --     top = 0,
    --     bottom = 1,
    -- },
    -- 设置初始窗口宽度（列数）和高度（行数）
    initial_cols = 138,  -- 设置为 100 列
    initial_rows = 38,   -- 设置为 30 行
}
-- Highway
-- Horizon
-- iterm2 light background
-- iterm2 tango light
-- primary
-- tomorrow
-- xcode light

-- config.color_scheme = 'Tomorrow'
config.color_scheme = 'Tomorrow Night'
-- jetbrains darcula
-- mellow
-- molokai
-- monokai remastered
-- ollie
-- tomorrow night
-- xcode dark


-- 获取当前窗口的尺寸

-- wezterm.on('window-focus-changed', function(window, pane)
--     wezterm.log_info(
--         window:get_dimensions()
--     )
--   end)


  wezterm.on('show-window-position', function(window, pane)
    window:set_position(730, 370)
  end)


config.keys = {
      {
        key = "P",  -- 设置快捷键为 Ctrl+Shift+P
        mods = "CTRL|SHIFT",
        action = wezterm.action.EmitEvent("show-window-position"),
      },
    }

return config
