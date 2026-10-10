## Accessibility fixes
- Added explicit accessible names and descriptions to interactive `QPushButton` widgets in the Welcome App to provide full context to screen readers and assistive technologies.

## UX improvements
- Enhanced screen reader experience by conveying the action and tooltip details natively through accessibility APIs.

## Remaining usability risks
- The decorative icon labels in the feature cards might be read aloud awkwardly by some screen readers without explicit ARIA-hidden equivalents or accessible names.
