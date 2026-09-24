-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- NeOS's bootstrap keeps path setup out of this user config.
dofile((os.getenv("NEOS_PATH") or "/usr/share/neos") .. "/default/hypr/bootstrap.lua")

-- Disable all NeOS default bindings. Add your own in hypr/bindings.lua.
-- neos_default_bindings = false
--
-- Or disable only bindings for NeOS's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- neos_preinstalled_bindings = false

-- Load NeOS defaults.
require("default.hypr.neos")

-- Put your personal overrides in these files. They're loaded after NeOS's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })
