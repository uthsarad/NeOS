# Palette Report

## UX Enhancements & Accessibility Fixes
- Improved the newly added telemetry opt-in checkbox in `neos-welcome-app`.
- **Contrast**: Increased the text color contrast of the checkbox label against the dark background (`#e6e9f2`).
- **Focus Indicators**: Added a visible focus state for keyboard navigation (border and translucent background).
- **Accessibility**: Added explicit `AccessibleName` and `AccessibleDescription` properties for screen readers.
- **Interactivity**: Set the cursor to `PointingHandCursor` for visual feedback on hover.
- **Keyboard Navigation**: Explicitly defined the tab order (`telemetry_checkbox` -> `try_btn` -> `install_btn`) to ensure logical keyboard flow.

## Usability Risks
- Still need to test how the dark mode UI performs in brightly lit environments.
- Monitor whether users understand the implications of the telemetry opt-in.
