-- Restore workspace layouts saved by neos-hyprland-workspace-layout-toggle.

local paths = require("default.hypr.paths")
local require_all = require("default.hypr.require_all")

local layouts_dir = paths.state_home .. "/neos/workspace-layouts"

require_all.files(layouts_dir, "neos.workspace-layouts", { reload = true })
