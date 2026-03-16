# Strategic Directive

## Phase 1 — Product Alignment Check
**What is the product trying to become?**
NeOS is a curated, snapshot-based Arch Linux desktop distribution aiming to deliver a Windows-familiar, highly stable, low-friction experience built upon KDE Plasma. It prioritizes predictable behavior, clean defaults, and robust update safety over flexibility or DIY paradigms.

**Are we building toward that?**
Yes, but critical path blockers and technical debt are currently impeding the release pipeline. The system's foundational components are strong, yet the primary build pipeline is failing, preventing the delivery of the ISO. The product's promise of stability must extend to its CI/CD processes.

**Are we solving the highest leverage problem?**
Yes. The highest leverage problem is the immediate unblocking of the ISO build process (fixing `pacman.conf`) and ensuring the resulting artifact is actually distributable (adding ISO size validation to CI/CD). Without these, the product cannot be shipped.

## Phase 2 — Technical Posture Review
**Is the system stable?**
The installed system is generally stable with strong security baselines, but the build system is currently broken (❌ BLOCKS ISO BUILD) due to a configuration mismatch (`DatabaseRequired` in the root `pacman.conf`).

**Is tech debt increasing?**
Yes. Technical debt exists in the form of missing CI validations (specifically, ISO size limits for GitHub Releases), undocumented architectural limitations (i686/aarch64 vs. x86_64), and brittle dependency handling in core scripts (e.g., `neos-autoupdate.sh`).

**Are we overbuilding?**
No. We are currently under-validating. The focus must be strictly on hardening the existing infrastructure rather than introducing new features.

## Phase 3 — Priority Selection
**Selection:** Stabilization / hardening

**Justification:** The project is blocked from building its primary artifact. Resolving the `pacman.conf` build error and implementing size constraints to ensure release viability are mandatory prerequisites before any further feature development or refinement can occur.

## Phase 4 — Controlled Scope Definition
**Targeted Files:**
- `pacman.conf` (root level)
- `.github/workflows/build-iso.yml`

**Maximum Allowed Surface Area:**
Modifications are strictly limited to fixing the root `pacman.conf` to unblock builds and adding ISO size validation to the GitHub Actions workflow. No new features, system configuration changes, or architectural shifts are permitted.

**Constraints for Architect:**
- In `pacman.conf` (root level), change `SigLevel` to `Required DatabaseOptional` to fix the build blocker. Do not modify `airootfs/etc/pacman.conf`.
- In `.github/workflows/build-iso.yml`, implement an ISO size validation step (max 2 GiB) using native bash arithmetic and `printf` for human-readable byte formatting.
- Ensure the `test` job in `.github/workflows/build-iso.yml` does not use `--privileged` container execution, adhering to the principle of least privilege.
- If text replacements are necessary, carefully verify the surrounding text using `sed` or targeted `grep` to ensure exact matches.

## Phase 5 — Delegation Strategy
- **Architect:** Implement the `pacman.conf` fix and the CI/CD size validation step.
- **Bolt:** Review the CI/CD size calculation logic to ensure it utilizes native bash integer arithmetic and `printf`, eliminating `awk` or other subprocess overhead.
- **Palette:** Ensure the CI/CD size validation failure message explicitly calculates and displays the exact excess size (`EXCESS_SIZE_MB`) and provides multi-line actionable remediation instructions.
- **Sentinel:** Review the `pacman.conf` modification to ensure it only applies to the build environment and verify the `test` job in CI correctly omits the `--privileged` flag.
