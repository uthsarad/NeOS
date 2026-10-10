# Risk & Priority Report

## Current Risks
1. **Documentation Drift:** The shipped documentation (`HANDBOOK.md`, `BOOTSTRAP.md`, `TROUBLESHOOTING.md`) contains inaccurate paths and claims that contradict the current repository state (e.g., referring to `airootfs/` directly instead of `profile/airootfs/`). This confuses users and contributors.
2. **Unverified CI Gates:** Several tests in the CI pipeline degrade to static greps because required dependencies (ruby, go, dotnet) are missing in the test environment.

## Mitigations
- **Immediate action:** Architect is tasked with fixing the documentation drift to restore alignment between the docs and the codebase.
- **Next steps (Future scope):** Address the CI gate dependencies to ensure tests run accurately.
