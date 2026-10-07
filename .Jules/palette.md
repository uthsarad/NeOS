## 2024-10-07 - Text Clipping on PyQt Dialogs
**Learning:** PyQt `QLabel` widgets can silently clip longer text in fixed-width layouts or on systems with scaled fonts. Standard alignment properties do not implicitly break text into multiple lines.
**Action:** Always explicitly invoke `.setWordWrap(True)` on QLabels rendering descriptive text or dynamic system information to ensure it flows nicely without overflow truncation.
