## 2026-10-11 - PyQt Interactive Widget Accessibility
**Learning:** In PyQt applications, screen readers may not consistently announce tooltips as helpful context for interactive widgets like buttons unless explicitly mapped to accessibility properties.
**Action:** Always assign explicit accessible names and descriptions using `.setAccessibleName()` and `.setAccessibleDescription()` when creating interactive components to ensure full screen reader support and context delivery.
