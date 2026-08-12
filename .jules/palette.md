## 2026-02-18 - SDDM QML Accessibility
**Learning:** When updating KDE Plasma SDDM custom QML themes, non-native UI components like Rectangle do not automatically inherit tab-navigation or focus states. This breaks keyboard accessibility.
**Action:** Explicitly bind KeyNavigation.tab, activeFocusOnTab: true, and keyboard events (e.g., Keys.onReturnPressed, Keys.onEnterPressed) to ensure focus flows logically.
## 2024-08-02 - SDDM QML Session Selector Keyboard Nav
**Learning:** The session selector and power actions in the SDDM theme were implemented directly as Text elements which do not support tab-navigation natively.
**Action:** Wrapped the elements in Rectangle items, explicitly bound activeFocusOnTab: true, updated KeyNavigation.tab for circular flow, and mapped Keys.onReturnPressed to ensure complete keyboard navigation functionality.
## 2026-02-18 - Discover Offline Updates Experience
**Learning:** By default, KDE Discover updates packages live while the desktop environment is running, which can lead to instability and unexpected crashes if a core library is replaced out from under a running app.
**Action:** Configured `UseOfflineUpdates=true` in `discoverrc` to align the update flow with a more stable, non-intrusive Windows-familiar offline update paradigm.
## 2026-02-18 - SDDM QML Accessibility Roles
**Learning:** Even if custom QML components are styled to look like inputs and buttons and support keyboard navigation, screen readers won't know their semantic purpose without explicit accessibility roles and names.
**Action:** Added `Accessible.role: Accessible.EditableText`, `Accessible.role: Accessible.Button`, and `Accessible.name` attributes to the custom username/password inputs and login/power action buttons in `Main.qml`.
## 2026-02-18 - kdialog semantic error states
**Learning:** When using KDE kdialog in shell scripts for error states, generic `--msgbox` flags are not properly announced as errors by assistive technologies like Orca.
**Action:** Use semantic flags like `--error` instead of generic `--msgbox` to ensure proper announcement and provide standard visual/audio cues.
## 2026-02-17 - Visual Anchoring in Dialogs
**Learning:** Text-heavy configuration and status dialogs without visual anchors require higher cognitive effort to parse, especially for neurodivergent users or those relying on screen magnifiers. Generic icons are insufficient; contextually relevant semantic icons (like `preferences-system` or `dialog-information`) significantly improve scanability.
**Action:** Always verify the availability of standard semantic system icons (e.g., using `find /usr/share/icons`) and inject them via `--icon` in text-based dialogs (`kdialog`) to provide immediate visual context.
## 2024-05-15 - Helpful Empty States in Terminal/CLI wrappers
**Learning:** Displaying empty output from CLI tools (like `snapper list`) in a GUI dialog (like `kdialog --textbox`) is extremely confusing for users, as it looks like a rendering bug or lack of data rather than an explicit "zero items" state.
**Action:** Always intercept CLI outputs that result in empty lists and replace them with semantic empty states (e.g. `kdialog --msgbox`) that explain *why* it's empty and *what* the user can do about it.
## 2026-08-12 - Semantic Context in Legal/About Dialogs
**Learning:** Generic titles like "System Licensing" can lack immediate context when opened as standalone text boxes in `kdialog`.
**Action:** Always prepend contextual application or system names (e.g., "About NeOS - System Licensing") to provide immediate clarity to the user.
