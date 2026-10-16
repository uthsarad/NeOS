## 2026-10-16 - PyQt Accessibility Context and Text Clipping
**Learning:** PyQt does not automatically map tooltips or standard text to accessibility attributes for screen readers, and text in QLabels can clip if word wrapping is not explicitly enabled.
**Action:** Always assign explicit `.setAccessibleName()` and `.setAccessibleDescription()` to interactive widgets, and call `.setWordWrap(True)` on user-facing QLabels to ensure accessibility and responsive text rendering.
