## 2024-10-08 - Accessible names in PyQt
**Learning:** In PyQt applications, screen reader context for interactive widgets (e.g., `QPushButton`) is not automatically inferred from their text or tooltips.
**Action:** Always explicitly assign accessible names and descriptions using `.setAccessibleName()` and `.setAccessibleDescription()` to improve accessibility.
