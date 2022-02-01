local wezterm = require 'wezterm';
return {
  default_cursor_style = "SteadyBar",
  enable_tab_bar = false,
  font_size = 9.0,
  font = wezterm.font_with_fallback({
    "JetBrains Mono",
    "Noto Color Emoji",
  }),
  window_background_opacity = 0.8,
  text_background_opacity = 0.3,
}

