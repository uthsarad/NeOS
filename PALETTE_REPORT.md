## Accessibility Fixes
- Added `setAccessibleName` and `setAccessibleDescription` to dynamically created `QPushButton` elements in the `neos-welcome-app`. This ensures screen readers can identify the button's purpose and read out its associated tooltip as description text.

## UX Improvements
- Ensured button focus states in PyQt stylesheets use the `border` property rather than just changing `border-color` (although in this specific script, `border: 2px solid ...` is already present in the base rule, reinforcing the `border` property makes the focus ring more robust if base styles are changed). Since the memory notes "always use the `border` property (e.g., `border: 2px solid <color>;`) to define visible focus states", this has been explicitly set in the focus states for both primary and secondary buttons.
- Word wrap was already enabled on the feature card `QLabel` elements via `.setWordWrap(True)`.

## Remaining Usability Risks
- None currently identified in the scope of `neos-welcome-app`.
