o.bind("SUPER + SPACE", "NeOS menu", "neos-menu toggle")
o.bind("SUPER + ALT + SPACE", "Apps menu", "neos-menu toggle apps")
o.bind("SUPER + CTRL + E", "Emojis", "neos-shell shell toggle neos.emojis")
o.bind("SUPER + CTRL + C", "Capture menu", "neos-menu toggle capture")
o.bind("SUPER + CTRL + O", "Toggle menu", "neos-menu toggle toggle")
o.bind("SUPER + CTRL + H", "Hardware menu", "neos-menu toggle hardware")
o.bind("SUPER + SHIFT + code:201", "NeOS menu", "neos-menu toggle root")
o.bind("SUPER + ESCAPE", "System menu", "neos-menu toggle system")
o.bind("XF86PowerOff", "Power menu", "neos-menu toggle system", { locked = true })
o.bind("SUPER + K", "Keybindings", "neos-menu-keybindings")
o.bind("SUPER + ALT + K", "Tmux keybindings", "neos-menu-tmux-keybindings")
o.bind("SUPER + CTRL + K", "Herdr keybindings", "neos-menu-herdr-keybindings")
o.bind("SUPER + CTRL + Q", "Calculator", "omacalc")
o.bind("XF86Calculator", "Calculator", "omacalc")

o.bind_toggle("SUPER + SHIFT + SPACE", "Toggle top bar", "bar")
o.bind("SUPER + CTRL + SPACE", "Background switcher", "neos-menu toggle background")
o.bind("SUPER + SHIFT + CTRL + SPACE", "Theme menu", "neos-menu toggle theme")
o.bind("SUPER + BACKSPACE", "Toggle window transparency", "neos-hyprland-window-transparency-toggle")
o.bind("SUPER + SHIFT + BACKSPACE", "Toggle window gaps", "neos-hyprland-window-gaps-toggle")
o.bind("SUPER + CTRL + BACKSPACE", "Toggle single-window square aspect", "neos-hyprland-window-single-square-aspect-toggle")

-- xkbcommon names the comma keysym "comma"; the upper-case "COMMA" does not match.
o.bind("SUPER + comma", "Dismiss last notification", "neos-shell notifications dismissOne")
o.bind("SUPER + SHIFT + comma", "Dismiss all notifications", "neos-shell notifications dismissAll")
o.bind_toggle("SUPER + CTRL + comma", "Toggle silencing notifications", "notification-silencing")
o.bind("SUPER + ALT + comma", "Invoke last notification", "neos-shell notifications invokeLast")
o.bind("SUPER + SHIFT + ALT + comma", "Open notification history", "neos-shell notifications showHistory")

o.bind_toggle("SUPER + CTRL + I", "Toggle locking on idle", "idle")
o.bind_toggle("SUPER + CTRL + N", "Toggle nightlight", "nightlight")
o.bind("SUPER + CTRL + Delete", "Toggle laptop display", "neos-hyprland-monitor-internal toggle")
o.bind("SUPER + CTRL + ALT + Delete", "Toggle laptop display mirroring", "neos-hyprland-monitor-internal-mirror toggle")
o.bind("switch:on:Lid Switch", nil, "neos-system-lid-close", { locked = true })
o.bind("switch:off:Lid Switch", nil, "neos-hyprland-monitor-clamshell", { locked = true })

o.bind("PRINT", "Screenshot", "neos-capture-screenshot")
o.bind("ALT + PRINT", "Screenrecording", "neos-capture-screenrecording --stop-recording || neos-menu toggle trigger.capture.screenrecord")
o.bind("SUPER + ALT + code:34", "Make webcam overlay smaller", "neos-capture-webcam-resize smaller")
o.bind("SUPER + ALT + code:35", "Make webcam overlay larger", "neos-capture-webcam-resize larger")
o.bind("SUPER + PRINT", "Color picker", "pkill hyprpicker || hyprpicker -a")
o.bind("SUPER + CTRL + PRINT", "Extract text (OCR) from screenshot", "neos-capture-text")

-- Keyboard control for the slurp region picker (see neos-capture-region).
-- The binds live exactly as long as a selection layer is on screen (slurp
-- opens one per monitor), so they cannot leak or get stuck.
-- Unbinding by key would take a same-key binding out of the user's own config
-- with it, so each handle is kept and removed individually.
local selection_layers = 0
local selection_binds = {}

hl.on("layer.opened", function(layer)
  if layer.namespace == "selection" then
    selection_layers = selection_layers + 1
    if selection_layers == 1 then
      selection_binds = {
        hl.bind("RETURN", hl.dsp.exec_cmd("neos-capture-region --take-window"), { description = "Capture highlighted window" }),
        hl.bind("CTRL + RETURN", hl.dsp.exec_cmd("neos-capture-region --take-fullscreen"), { description = "Capture entire screen" }),
        hl.bind("TAB", hl.dsp.exec_cmd("neos-capture-region --select-window next"), { description = "Select next window to capture" }),
        hl.bind("CTRL + TAB", hl.dsp.exec_cmd("neos-capture-region --select-window prev"), { description = "Select previous window to capture" }),
      }
      for _, direction in ipairs({ "left", "right", "up", "down" }) do
        table.insert(
          selection_binds,
          hl.bind(direction:upper(), hl.dsp.exec_cmd("neos-capture-region --select-window " .. direction), { description = "Select window to capture" })
        )
      end
    end
  end
end)

hl.on("layer.closed", function(layer)
  if layer.namespace == "selection" and selection_layers > 0 then
    selection_layers = selection_layers - 1
    if selection_layers == 0 then
      for _, keybind in ipairs(selection_binds) do
        keybind:unbind()
      end
      selection_binds = {}
    end
  end
end)

o.bind("SUPER + CTRL + S", "Share", "neos-menu toggle share")

o.bind("SUPER + CTRL + PERIOD", "Transcode", "neos-transcode")

o.bind("SUPER + CTRL + R", "Set reminder", "neos-menu toggle reminder-set")
o.bind("SUPER + CTRL + ALT + R", "Show reminders", "neos-reminder show")
o.bind("SUPER + SHIFT + CTRL + R", "Clear reminders", "neos-reminder clear")

o.bind("SUPER + CTRL + ALT + T", "Show time", "neos-notification-time")
o.bind("SUPER + CTRL + ALT + B", "Show battery remaining", "neos-notification-battery")
o.bind("SUPER + CTRL + ALT + W", "Toggle weather", "neos-notification-weather")

o.bind("SUPER + SHIFT + CTRL + A", "Agent", "neos-agent --pick")
o.bind("SUPER + CTRL + A", "Audio", "neos-shell shell toggle neos.audio")
o.bind("SUPER + CTRL + B", "Bluetooth", "neos-shell shell toggle neos.bluetooth")
o.bind("SUPER + CTRL + D", "Display", "neos-shell shell toggle neos.monitor")
o.bind("SUPER + CTRL + ALT + D", "Calendar", "neos-shell shell toggle neos.clock")
o.bind("SUPER + CTRL + W", "Network", "neos-shell shell toggle neos.network")
o.bind("SUPER + CTRL + P", "Power", "neos-shell shell toggle neos.power")
o.bind("SUPER + CTRL + T", "Activity", { tui = "btop" })

-- The letters above name a panel; the numbers count them. 1 is the leftmost
-- panel in the bar's right section, and a widget with no panel of its own (the
-- tray) is not counted, so the number matches the icon a user would point at.
-- A bar with fewer panels than this leaves the tail of the range doing nothing.
for panel = 1, 9 do
  o.bind(
    "SUPER + CTRL + code:" .. tostring(panel + 9),
    "Bar panel " .. panel,
    "neos-shell -q shell togglePanelAt right " .. panel
  )
end

o.bind("SUPER + CTRL + Z", "Zoom in", function()
  local zoom = hl.get_config("cursor.zoom_factor") or 1
  hl.config({ cursor = { zoom_factor = zoom + 1 } })
end)

o.bind("SUPER + CTRL + ALT + Z", "Reset zoom", function()
  hl.config({ cursor = { zoom_factor = 1 } })
end)

o.bind("SUPER + CTRL + L", "Lock system", "neos-system-lock")
