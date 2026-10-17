## 2026-10-17 - Accessible Names in PyQt
**Learning:** By default, PyQt tooltips do not reliably provide full context to screen readers unless explicitly bound using `setAccessibleDescription`.
**Action:** Always map tooltips and display text to `setAccessibleName` and `setAccessibleDescription` for all `QPushButton` and interactive widgets in PyQt applications to ensure screen reader compatibility.
