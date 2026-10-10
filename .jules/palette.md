## 2026-10-10 - PyQt Accessible Names and Descriptions
**Learning:** Screen readers often struggle with PyQt widgets if they only have tooltips. Interactive widgets like `QPushButton` need explicit accessible names and descriptions to provide full context to assistive technologies.
**Action:** Always assign explicit accessible names and descriptions to interactive PyQt widgets using `.setAccessibleName()` and `.setAccessibleDescription()`.
