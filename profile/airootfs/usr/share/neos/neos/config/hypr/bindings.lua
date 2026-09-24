-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   neos menu keybindings --print

-- To disable every NeOS default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.neos"), then add
-- only the bindings you want below:
--   neos_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   neos_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the NeOS root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "NeOS menu", "neos-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "neos-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "neos-shell shell toggle neos.emojis")
