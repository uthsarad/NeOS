## 2025-05-24 - Slideshow Interaction Models
**Learning:** Purely timer-based slideshows frustrate users reading content. Hover-to-pause is insufficient for keyboard users.
**Action:** Implemented a reference-counted `pauseLocks` system in QML. Allows multiple sources (hover, focus, window state) to request a pause without race conditions.

## 2025-05-24 - Calamares Accessibility
**Learning:** Calamares QML modules need explicit `Accessible.role` and `Keys.onPressed` handlers. Standard QML items are often invisible to screen readers and keyboard navigation.
**Action:** Added `activeFocusOnTab: true`, `Accessible.role: Accessible.Button`, and explicit focus visualizations (scale/border) to all interactive slideshow elements.
