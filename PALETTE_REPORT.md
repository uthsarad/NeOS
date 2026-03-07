# Palette Report: Pre-build CI Validation and Config Fixes

## Accessibility Fixes
- Added clear, multi-line, structural instructions to error output logs across the repository, improving readability and accessibility for users dealing with CI limits and test regressions. Byte values in CI are now printed with human-readable formatting.
- Replaced ambiguous, singular error lines with bulleted lists of recovery instructions in `tools/neos-profile-audit` error logs to allow users to act faster upon failure.
- Updated `tests/verify_build_profile.sh` and `tests/verify_mkinitcpio.sh` script to match formatting conventions and structure multi-line '💡 How to fix:' blocks.

## UX Improvements
- **CI Readability:** Modified `.github/workflows/build-iso.yml` to display byte value alongside a MiB conversion so users reviewing log artifacts don't have to perform math to understand the constraint check.
- **CLI Readability:** Structured Rust tooling validation errors to be actionable instead of solely diagnostic.

## Remaining Usability Risks
- Other tests in `tests/` likely still have unstyled singular error outputs that may be ambiguous.
- CI pipeline logs can still get buried deep under execution layers. Surfacing key metrics on CI failure to an upper-level PR comment or summary annotation could improve developer experience.