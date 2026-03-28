# STRATEGIC DIRECTIVE

## PHASE 1 — Product Alignment Check
- **What is the product trying to become?** NeOS is a curated rolling-release, Arch-based desktop OS prioritizing a Windows-familiar KDE Plasma experience and sustainable long-term maintenance.
- **Are we building toward that?** Yes, but operational predictability is currently threatened by a lack of CI/CD constraints.
- **Are we solving the highest leverage problem?** Yes. The `DEEP_AUDIT.md` highlighted a High Priority risk: "Missing ISO Size Validation in CI/CD." ISOs larger than 2 GiB cannot be uploaded to GitHub Releases, causing silent release failures and preventing users from downloading the distribution.

## PHASE 2 — Technical Posture Review
- **Is the system stable?** The core ISO generation works, but the CI release pipeline is fragile because it lacks enforcement of hard platform constraints.
- **Is tech debt increasing?** Yes, relying on passive documentation (e.g., "target staying under 2 GiB") rather than active pipeline enforcement creates operational debt and risks broken releases.
- **Are we overbuilding?** No. A simple size check within the existing `.github/workflows/build-iso.yml` before the release step is a minimal, necessary addition.

## PHASE 3 — Priority Selection
- **Selected Priority:** Infrastructure improvement (CI/CD pipeline hardening).

## PHASE 4 — Controlled Scope Definition
- **Exact files likely impacted:**
  - `.github/workflows/build-iso.yml`
- **Maximum allowed surface area:** The Implementation Lead (Architect) must strictly add a single validation step to the existing GitHub Actions workflow. No new features, system logic changes, or other workflow modifications are permitted.
- **Constraints Architect must obey:**
  - The step must run after the ISO is built/prepared and before it is uploaded to GitHub Releases.
  - The step must verify that the built ISO file is strictly less than 2 GiB (2 * 1024 * 1024 * 1024 bytes).
  - If the ISO exceeds this limit, the workflow must fail (exit 1).
  - The logic must only affect the `main` branch/release flow.
  - Out-of-scope issues from past audit reports (e.g., architecture support, dependency validation, systemd sandboxing) have either been resolved or are explicitly excluded from this task to enforce the single coherent deliverable constraint.

## PHASE 5 — Delegation Strategy
- **Architect builds:** Implements the ISO size validation step in `.github/workflows/build-iso.yml`.
- **Bolt optimizes:** Ensures the size calculation uses native tools (like `stat` and bash arithmetic) to minimize subprocess overhead, avoiding slow search tools like `find` where simple globbing suffices.
- **Palette enhances:** Ensures the CI failure output provides a clear, actionable message detailing the actual size versus the limit, reducing cognitive load for developers diagnosing the failure.
- **Sentinel audits:** Verifies that the workflow modifications respect the existing security boundaries (e.g., actor checks) and that the size check logic cannot be manipulated or bypassed by untrusted PRs.
