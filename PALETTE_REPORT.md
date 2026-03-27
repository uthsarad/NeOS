# Palette UX Report

## Accessibility Fixes
- None needed in bash scripts.

## UX Improvements
- **Actionable Admin Error Message:** Improved the error message in `neos-autoupdate.sh` when `snapper` is missing. The new message clearly explains that `snapper` is not installed, what the consequences are (automatic Btrfs pre/post snapshots disabled, update skipped), and provides actionable instructions on how to resolve the issue (install `snapper` and configure a root configuration).

## Remaining Usability Risks
- Other system administrative scripts might also have cryptic errors that could benefit from clearer, more actionable messaging.
