# Strategic Directive

PHASE 1 — Product Alignment Check
The product aims to provide a predictable, Windows-familiar Arch-based experience. We are building toward that, but our validation infrastructure is producing false negatives during static audits due to environmental dependencies. We must solve the highest leverage problem: stabilizing the test pipeline to ensure consistent quality gates without masking actual failures.

PHASE 2 — Technical Posture Review
The core system configuration is stable, as verified by recent audits. However, tech debt exists in our testing infrastructure:
- `verify_iso_smoketest.sh` fails in static audit environments where no ISO is built.
- `verify_mirrorlist_connectivity.sh` is brittle and fails on unreachable networks.
We must harden these tests to be context-aware.

PHASE 3 — Priority Selection
Stabilization / hardening

PHASE 4 — Controlled Scope Definition
- Exact files likely impacted: `tests/verify_iso_smoketest.sh`, `tests/verify_mirrorlist_connectivity.sh`.
- Maximum allowed surface area: CI test scripts exclusively. No changes to `airootfs/` or bootloader configurations. No modifications to GitHub Actions workflows.
- Constraints Architect must obey: Tests must gracefully detect static environments and skip irrelevant checks, but must still enforce strict validation during a true ISO build.

PHASE 5 — Delegation Strategy
- Architect builds environment-aware logic into test scripts.
- Bolt optimizes test execution to minimize subshell and timeout overhead.
- Palette enhances terminal output for skipped vs. failed tests.
- Sentinel ensures no code execution vulnerabilities are introduced via mirror parsing.
