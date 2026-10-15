## 2026-10-15 - PyQt Accessibility and Word Wrapping Learnings
**Learning:** PyQt interactive widgets like QPushButton do not automatically inherit rich screen reader properties from their text or tooltips in all environments; explicitly setting setAccessibleName and setAccessibleDescription is required. Additionally, QLabel widgets are prone to text clipping without setWordWrap(True).
**Action:** Always assign explicit accessible metadata for screen readers on PyQt controls and ensure word wrapping is enabled on UI text elements to prevent truncation.
