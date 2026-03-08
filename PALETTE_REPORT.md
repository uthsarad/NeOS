# Palette Report

## Accessibility Fixes
- None required for this task.

## UX Improvements
- Structured the ISO size validation error message in the CI workflow into a multi-line format with a `💡 How to fix:` section, significantly reducing developer cognitive load during failed build investigations.
- Added the exact overflow amount in MiB (`EXCESS_SIZE_MB`) using native bash arithmetic to provide developers with immediate, actionable context regarding how much size reduction is needed.

## Remaining Usability Risks
- No critical usability risks remaining in the CI output size validation block.
