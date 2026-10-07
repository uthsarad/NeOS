## Accessibility Fixes
- Added accessible names and descriptions to interactive buttons (QPushButtons) so screen readers accurately read out button context.

## UX Improvements
- Added word wrapping (`setWordWrap(True)`) to title, subtitle, and version text QLabels in the welcome app to prevent unwanted text clipping across various screen resolutions and text scalings.

## Remaining Usability Risks
- Hardcoded sizes on some layout components might cause clipping if translations are introduced in the future.
