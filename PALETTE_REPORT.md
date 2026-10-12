## Accessibility fixes
- Added explicit accessible names and descriptions to main interactive buttons (QPushButtons) in the NeOS welcome app to provide necessary context for screen readers.

## UX improvements
- Enabled word-wrapping on subtitle and version labels (QLabel) in the welcome app to prevent unexpected text clipping on varying screen densities or font sizes.

## Remaining usability risks
- Feature cards are implemented as generic QFrames and lack semantic accessibility roles or grouping for screen readers.
