## 2026-02-18 - SDDM QML Accessibility
**Learning:** When updating KDE Plasma SDDM custom QML themes, non-native UI components like Rectangle do not automatically inherit tab-navigation or focus states. This breaks keyboard accessibility.
**Action:** Explicitly bind KeyNavigation.tab, activeFocusOnTab: true, and keyboard events (e.g., Keys.onReturnPressed, Keys.onEnterPressed) to ensure focus flows logically.
