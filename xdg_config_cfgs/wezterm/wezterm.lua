local wezterm = require("wezterm")
local config = {
    -- front_end = "WebGpu",
    -- front_end = "OpenGL",
    tab_bar_at_bottom = true,
    hide_tab_bar_if_only_one_tab = true,
    -- font = wezterm.font('JetBrainsMono NFM', { weight = 'Regular', italic = true })
    -- color_scheme = '3024 (light) (terminal.sexy)',
    window_background_opacity = 0.6,
    macos_window_background_blur = 85,
}

return config
