# Architect Report — Repo Hygiene & Audit Consolidation (2026.09.11)

## Inline Architecture Brief

- **Single source of truth for profile auditing**: `tools/neos-profile-audit` (Rust) is the canonical auditor — it is a strict superset of every check the Go `runAudit`, Ruby `audit_profile`, and all five `tools/polyglot` auditors perform (required files, duplicate package detection, required packages, kernel invariant, mirrorlist servers, profiledef validation, injection hardening), and it is the only audit implementation CI actually executes (it installs `rust`; Go/Ruby/polyglot tests always fell through to static-grep fallbacks in CI).
- **Rationale for keeping the other tools**: C# `NeosDiagnostics` is NOT a duplicate — it audits a distinct domain (security sysctl, ZRAM performance, pacman signature posture). Go `neosctl` keeps its unique high-value feature (`rank-mirrors` concurrency benchmark). Ruby keeps orchestration (`generate_manifests`, `run_tests`, Rakefile).
- **Duplicate report relocation**: the 8 root-level agent reports (`ARCHITECT_REPORT.md`, `ARCHITECT_SCOPE.json`, `BOLT_REPORT.md`, `PALETTE_REPORT.md`, `RISK_REPORT.md`, `SENTINEL_REPORT.md`, `SPECIALIST_GUIDANCE.json`, `STRATEGIC_DIRECTIVE.md`) duplicate the historical record already kept under `reports/vX.Y.Z/` and are appended in place by automated agents. They move to `reports/v2026.09.11/`; `ai/tasks/*.json` stay as active task-state files.
- **Install manifests stay tracked but refreshed**: `neos-packages.txt`/`neos-overlay.txt` remain committed (per owner decision) and are regenerated via `tools/gen-manifests.sh` to eliminate drift. The generator remains the single source of truth run by both `build.sh` and CI.
- **Build-artifact hygiene**: `.gitignore` gains `.NET` `bin/`/`obj/` rules so `tools/NeosDiagnostics` build output can never be committed.

## Risk Assessment

- **Low risk**: removed implementations were redundant subsets; every retained check is covered by the Rust auditor + 38 remaining `tests/verify_*.sh` gates + CI.
- **CI compatibility**: no workflow changes needed — CI's test loop skips deleted tests automatically; `rust` is already installed for the Rust auditor; ShellCheck/Trivy unaffected.
- **Breaking**: `neosctl audit` and `rake audit` subcommands are removed (redundant); `cargo test` retained for the canonical auditor.
