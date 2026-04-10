# Strategic Directive

## PHASE 1 — Product Alignment Check
- **What is the product trying to become?** NeOS aims to be a curated, predictable rolling-release Arch-based desktop OS with a Windows-familiar KDE Plasma experience.
- **Are we building toward that?** Yes, the recent implementations of systemd sandboxing, automated Btrfs snapshot hooks, and verified QML enhancements indicate a trajectory towards a resilient, polished desktop. However, the system's reliance on custom bash scripts introduces maintainability risk.
- **Are we solving the highest leverage problem?** Ensuring the robustness of our custom scripts via automated CI validation (ShellCheck) is the highest leverage infrastructure improvement we can make to prevent regressions and security vulnerabilities before the beta release.

## PHASE 2 — Technical Posture Review
- **Is the system stable?** Mostly. 22 out of 24 verification tests pass, with 2 non-blocking environmental failures. Critical issues like the `pacman.conf` SigLevel blocking builds have been resolved.
- **Is tech debt increasing?** Yes, due to a proliferation of custom Bash scripts (`tests/verify_*.sh`, `airootfs/usr/local/bin/*`) lacking automated static analysis.
- **Are we overbuilding?** No, but we are under-validating our custom logic.

## PHASE 3 — Priority Selection
- **Selected Priority:** Infrastructure improvement
- **Rationale:** Integrating ShellCheck into the CI pipeline directly addresses the technical debt identified in Phase 2 and satisfies long-term improvement item #14 ("Add Security Scanning: ShellCheck for bash scripts") from `AUDIT_ACTION_PLAN.md`.

## PHASE 4 — Controlled Scope Definition
- **Exact files likely impacted:** `.github/workflows/shellcheck.yml` (new)
- **Maximum allowed surface area:** Creation of a new GitHub Actions workflow file solely dedicated to running ShellCheck against `.sh` files and scripts without extensions in `airootfs/usr/local/bin/`. No existing production code or scripts should be modified in this run.
- **Constraints Architect must obey:** Must only create the CI workflow file. Must not attempt to "fix" any warnings ShellCheck finds in this pass; the goal is solely to establish the infrastructure.

## PHASE 5 — Delegation Strategy
- **Architect builds:** The ShellCheck GitHub Actions workflow (`.github/workflows/shellcheck.yml`).
- **Bolt optimizes:** Ensure the ShellCheck CI job runs quickly by targeting specific directories rather than performing an exhaustive, unoptimized find across the entire repository.
- **Palette enhances:** Ensure the ShellCheck output format in CI is readable, preferably using a structured format (like `gcc` or `tty`) that integrates well with GitHub Actions annotations.
- **Sentinel audits:** Review the workflow to ensure it uses official, pinned actions or secure execution environments to prevent supply chain risks.
