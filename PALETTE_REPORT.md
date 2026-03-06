# Palette Report

## Scope
Modified pre-build validation error messages for ISO size optimizations.

## Accessibility / UX Fixes
- **Improved Error Messaging:** Updated `tests/verify_iso_size.sh` to output clear, multi-line remediation instructions when `profiledef.sh` compression settings or `pacman.conf` `NoExtract` settings fail validation.
- **Actionability:** Error states now clearly point to the specific file and provide exact instructions on how to resolve the error rather than generic "found/not found" logging.

## Remaining Usability Risks
- The GitHub action workflow itself already outputs actionable UI errors with human-readable MiB sizes for the global 2GiB ISO limit, but other CI tests might still rely on terse single-line exit 1 statements.
