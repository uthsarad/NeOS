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

## 2024-05-24 - Semantic dialogs for Assistive Technologies
**Learning:** Using generic `--msgbox` flags in `kdialog` for error states prevents screen readers (like Orca) from announcing the dialog's severity or nature. Native semantic flags like `--error` are required to trigger appropriate accessibility cues.
**Action:** Always map UI dialog states (error, warning, info) to their precise semantic `kdialog` flag equivalents instead of relying solely on visual text content in generic message boxes.
