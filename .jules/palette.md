## 2026-10-14 - PyQt Accessible Attributes
**Learning:** PyQt widgets like QPushButton do not automatically expose tooltips or rich context to screen readers by default.
**Action:** Always map button text and tooltip text to .setAccessibleName() and .setAccessibleDescription() respectively when creating reusable interactive components in PyQt.
