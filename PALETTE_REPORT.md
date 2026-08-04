# Palette Report

## Accessibility Fixes
- Ensured Discover layout categorize defaults (`installedPageCategorize=true`) are set for better cognitive accessibility.
- **Keyboard Navigation in SDDM**: The session selector and power buttons at the bottom of the SDDM login screen were previously untabbable `Text` elements. I wrapped them in `Rectangle` elements and added explicit `activeFocusOnTab: true`, `KeyNavigation.tab`, and visual borders upon `activeFocus`. The tab navigation now flows seamlessly from the "Log In" button to the session selector, power buttons, and cycles back to the username field.

## UX Improvements
- Aligned update flow with Windows-familiar offline updates by setting `UseOfflineUpdates=true` in `discoverrc`.
- Added subtle visual borders to the session and power actions upon keyboard focus to clearly indicate which action is selected, solving the issue where keyboard-only users lacked visual focus feedback for non-primary actions.

## Remaining Usability Risks
- The theme wallpaper background currently depends on a configured background file. If it fails, the background is just a gradient. An additional empty state message might be helpful but wasn't critical for this session.
