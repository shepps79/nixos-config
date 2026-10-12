local wezterm = require 'wezterm'
local act = wezterm.action

local config = wezterm.config_builder()

-- Scroll 3 lines per wheel notch instead of 1. Only on the primary screen:
-- in full-screen apps (less, vim) the default turns the wheel into arrow keys.
config.mouse_bindings = {
  {
    event = { Down = { streak = 1, button = { WheelUp = 1 } } },
    mods = 'NONE',
    alt_screen = false,
    action = act.ScrollByLine(-3),
  },
  {
    event = { Down = { streak = 1, button = { WheelDown = 1 } } },
    mods = 'NONE',
    alt_screen = false,
    action = act.ScrollByLine(3),
  },
}

-- Generated into colors/ by noctalia. Keep this line here: if it's missing,
-- noctalia adds it with `sed -i`, which replaces the stow symlink with a copy.
config.color_scheme = "Noctalia"

return config
