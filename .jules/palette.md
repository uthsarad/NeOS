## 2026-10-12 - Screen Reader Context in PyQt
**Learning:** PyQt interactive widgets like `QPushButton` don't always expose optimal context to screen readers automatically, particularly when utilizing tooltips for secondary descriptions.
**Action:** Always explicitly assign `.setAccessibleName()` and `.setAccessibleDescription()` to key interactive widgets in PyQt applications to guarantee proper screen reader support.

## 2026-10-12 - Text Clipping in PyQt Labels
**Learning:** Hardcoded window sizes in PyQt can lead to `QLabel` text clipping if system fonts or DPI scaling change unexpectedly.
**Action:** Explicitly enable word wrapping via `.setWordWrap(True)` on multi-line or long user-facing labels to prevent arbitrary truncation.
