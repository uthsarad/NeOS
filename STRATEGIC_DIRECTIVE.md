# Strategic Directive

## Phase 1 — Product Alignment Check
**What is the product trying to become?**
NeOS is a curated, snapshot-based Arch Linux desktop distribution delivering Windows-level usability with Linux-level power. It bridges the gap between Arch flexibility and consumer reliability.

**Are we building toward that?**
Yes, but the foundation needs to accurately reflect our architecture limits to avoid user frustration. The "Windows-familiar experience" is fully realized on x86_64, but our experimental i686 and aarch64 architectures lack core features like the GUI installer and snapshots.

**Are we solving the highest leverage problem?**
The highest leverage problem now is expectation management and code maintainability. With critical build blockers and core service hardening (like `neos-autoupdate.sh` and `neos-driver-manager.service`) already addressed, we must clarify our architecture support model and improve the maintainability of our core package lists.

## Phase 2 — Technical Posture Review
**Is the system stable?**
Yes. The ISO builds successfully, size validation is active, and critical system services have been hardened with systemd sandboxing and dependency checks.

**Is tech debt increasing?**
Yes, in our documentation and package manifests. `packages.x86_64` lacks structural comments, making it hard to maintain compared to other architectures. Documentation still points to incorrect repository URLs and claims features on architectures that don't support them.

**Are we overbuilding?**
No, but we risk overpromising. We must explicitly document that i686 and aarch64 are experimental and do not feature the full NeOS GUI experience.

## Phase 3 — Priority Selection
**Selection:** Refinement of recent feature (Documentation & Architecture Definitions)

**Justification:** The system is functionally stable. We must address High and Medium priority audit items related to documentation and package maintainability (Items 3, 5, 6, and 10 from `DEEP_AUDIT.md`) to prepare for a public beta release.

## Phase 4 — Controlled Scope Definition
**Targeted Files:**
- `README.md`
- `docs/HANDBOOK.md`
- `CONTRIBUTING.md`
- `packages.x86_64`

**Maximum Allowed Surface Area:**
Modifications are strictly limited to updating URLs, adding explicit architecture limitations, and adding structural comments to the package manifest. No new features or system configuration changes are permitted.

**Constraints for Architect:**
- Do not modify `.github/workflows` or test scripts.
- Do not modify `profiledef.sh` or `pacman.conf`.
- Follow the exact comment structure defined in `DEEP_AUDIT.md` for `packages.x86_64`.
- Ensure all URLs point to `https://github.com/uthsarad/NeOS`.

## Phase 5 — Delegation Strategy
- **Architect:** Implement the documentation fixes and package manifest structure.
- **Bolt:** Ensure package manifest structural changes do not impact build parsing speed (though minimal impact is expected, `tests/verify_build_profile.sh` should still run quickly).
- **Palette:** Review the updated documentation for readability and ensure the architecture limitations are presented clearly to the user without causing alarm.
- **Sentinel:** Verify that the updated URLs point to the correct, trusted repository and do not introduce malicious links.
