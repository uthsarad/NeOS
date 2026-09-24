-- Essential application bindings.
o.bind("SUPER + RETURN", "Terminal", { neos = "terminal" })
o.bind("SUPER + SHIFT + RETURN", "Browser", { neos = "browser" })
o.bind("SUPER + SHIFT + F", "File manager", { neos = "nautilus" })
o.bind("SUPER + ALT + SHIFT + F", "File manager (cwd)", { neos = "nautilus-cwd" })
o.bind("SUPER + SHIFT + B", "Browser", { neos = "browser" })
o.bind("SUPER + SHIFT + ALT + B", "Browser (private)", { neos = "browser --private" })
o.bind("SUPER + SHIFT + N", "Editor", { neos = "editor" })

if o.preinstalled_bindings_enabled() then
  -- Bindings for preinstalled NeOS applications, TUIs, and web apps.
  o.bind("SUPER + ALT + RETURN", "Tmux", { neos = "terminal-tmux" })
  o.bind("SUPER + CTRL + RETURN", "Herdr", { neos = "terminal-herdr" })
  o.bind("SUPER + SHIFT + M", "Music", { neos = "spotify" })
  o.bind("SUPER + SHIFT + ALT + M", "Music TUI", { tui = "cliamp", focus = true })
  o.bind("SUPER + SHIFT + D", "Docker", { tui = "neos-launch-docker-tui" })
  o.bind("SUPER + SHIFT + G", "Signal", { neos = "signal" })
  o.bind("SUPER + SHIFT + O", "Obsidian", { launch = "obsidian", focus = "^obsidian$" })
  o.bind("SUPER + SHIFT + W", "Omawrite", { launch = "omawrite" })
  o.bind("SUPER + SHIFT + SLASH", "Passwords", { neos = "1password" })

  o.bind("SUPER + SHIFT + A", "ChatGPT", { webapp = "https://chatgpt.com" })
  o.bind("SUPER + SHIFT + ALT + A", "Grok", { webapp = "https://grok.com" })
  o.bind("SUPER + SHIFT + C", "Calendar", { webapp = "https://app.hey.com/calendar/weeks/" })
  o.bind("SUPER + SHIFT + E", "Email", { webapp = "https://app.hey.com" })
  o.bind("SUPER + SHIFT + ALT + E", "New email", { webapp = "https://app.hey.com/messages/new?display=standalone&new_window=true" })
  o.bind("SUPER + SHIFT + Y", "YouTube", { webapp = "https://youtube.com/" })
  o.bind("SUPER + SHIFT + ALT + G", "WhatsApp", { webapp = "https://web.whatsapp.com/", focus = true })
  o.bind( "SUPER + SHIFT + CTRL + G", "Google Messages", { webapp = "https://messages.google.com/web/conversations", focus = true })
  o.bind("SUPER + SHIFT + P", "Google Photos", { webapp = "https://photos.google.com/", focus = true })
  o.bind("SUPER + SHIFT + S", "Google Maps", { webapp = "https://maps.google.com/", focus = true })
  o.bind("SUPER + SHIFT + X", "X", { webapp = "https://x.com/" })
  o.bind("SUPER + SHIFT + ALT + X", "X Post", { webapp = "https://x.com/compose/post" })
end
