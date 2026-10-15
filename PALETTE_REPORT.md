## Accessibility Fixes
- Added explicitly assigned accessible names (setAccessibleName) and descriptions (setAccessibleDescription) to all QPushButton elements for robust screen reader context.

## UX Improvements
- Enabled word wrapping (setWordWrap(True)) on primary text QLabels (title, subtitle, version) to prevent text clipping during unusual font settings or window rendering edge cases.

## Remaining Usability Risks
- Screen reader announcements might not trigger automatically for feature cards since they are QFrames rather than native interactive widgets.
