# Risk & Priority Report
**Date:** 2026-04-01

## Active Risks
1.  **CI Test Brittleness (Medium):** Several tests in `tests/` assume specific environments (like existing ISO artifacts or perfect network reachability). This causes false positives in CI.
2.  **Environment Dependencies (Low):** Tests failing due to missing tools like PyYAML or ShellCheck.

## Priorities
1.  Make test scripts robust against missing optional dependencies (e.g., using `|| true` for linters).
2.  Ensure CI pipelines don't hang due to network connectivity checks.
