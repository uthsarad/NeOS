## 2026-02-18 - SDDM QML Accessibility
**Learning:** When updating KDE Plasma SDDM custom QML themes, non-native UI components like Rectangle do not automatically inherit tab-navigation or focus states. This breaks keyboard accessibility.
**Action:** Explicitly bind KeyNavigation.tab, activeFocusOnTab: true, and keyboard events (e.g., Keys.onReturnPressed, Keys.onEnterPressed) to ensure focus flows logically.
## 2024-08-02 - SDDM QML Session Selector Keyboard Nav
**Learning:** The session selector and power actions in the SDDM theme were implemented directly as Text elements which do not support tab-navigation natively.
**Action:** Wrapped the elements in Rectangle items, explicitly bound activeFocusOnTab: true, updated KeyNavigation.tab for circular flow, and mapped Keys.onReturnPressed to ensure complete keyboard navigation functionality.
