local wezterm = require("wezterm")
-- Import our new module (put this near the top of your wezterm.lua)
local appearance = require 'appearance'

local config = {
    -- front_end = "WebGpu",
    -- front_end = "OpenGL",
    tab_bar_at_bottom = true,
    hide_tab_bar_if_only_one_tab = true,
    -- font = wezterm.font('JetBrainsMono NFM', { weight = 'Regular', italic = true })
    -- font = wezterm.font('MesloLGS NFM', { weight='Regular', style=Normal }),
    -- color_scheme = '3024 (light) (terminal.sexy)',
    window_background_opacity = 0.625,
    macos_window_background_blur = 45,
}

if appearance.is_dark() then
    wezterm.log_info("is dark -- " .. wezterm.hostname())
else
    wezterm.log_info("is light -- " .. wezterm.hostname())
    config.color_scheme = '3024 (light) (terminal.sexy)'
end

return config
