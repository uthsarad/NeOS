## Accessibility fixes
* Explicitly bound `.setAccessibleName()` and `.setAccessibleDescription()` to dynamically generated `QPushButton` instances in `neos-welcome-app` to ensure proper context for screen readers.
* Added `.setWordWrap(True)` to the application subtitle label to prevent text clipping on smaller resolutions or scaled displays.

## UX improvements
* Screen reader users now hear the button's intent clearly without needing to hover for tooltips.
* Improved robustness of the interface for varying font scaling and DPI settings by ensuring text can wrap.

## Remaining usability risks
* The application currently assumes a dark theme. If a user has a high-contrast light theme active at the window manager level, the hardcoded dark gradient and colors may reduce readability.
* The feature cards rely on monospace/standard text glyphs which might be announced cryptically by some screen readers (e.g., announcing "check mark" randomly without context before "Secure by default"). Explicit accessible names on these cards might be beneficial in the future.
