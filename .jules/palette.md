## 2026-10-13 - Accessible Properties in PyQt
**Learning:** In PyQt applications, screen readers often miss context from tooltips alone. Interactive widgets like `QPushButton` need explicit `.setAccessibleName()` and `.setAccessibleDescription()` for full screen reader support.
**Action:** Always map the user-facing text to the accessible name and the descriptive tooltip to the accessible description when constructing custom or dynamically generated widgets.
