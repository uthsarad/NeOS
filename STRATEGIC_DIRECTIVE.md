# Strategic Directive

## PHASE 1 — Product Alignment Check
- What is the product trying to become? NeOS aims to be a curated Arch Linux distribution delivering Windows-level usability with Linux-level power.
- Are we building toward that? Yes, the focus is on a familiar desktop paradigm, stability, and out-of-the-box usability.
- Are we solving the highest leverage problem? The recent execution of verification tests revealed missing Calamares configuration modules (`fstab.conf` and `users.conf`), which are critical for the Phase 3 (Installer and First-Boot UX) roadmap milestone. Addressing these missing modules is the highest leverage problem to ensure installer reliability.

## PHASE 2 — Technical Posture Review
- Is the system stable? Yes, the core system is stable.
- Is tech debt increasing? Technical debt is low, but the missing Calamares modules cause warnings in the verification suite and represent a gap in the installer configuration.
- Are we overbuilding? No, we are addressing missing foundational components for the installer.

## PHASE 3 — Priority Selection
- Selected Priority: New feature implementation / Stabilization
- Rationale: The missing `fstab.conf` and `users.conf` modules must be implemented to fulfill the installer UX goals and ensure the verification suite passes cleanly.

## PHASE 4 — Controlled Scope Definition
- Exact files likely impacted: `profile/airootfs/etc/calamares/modules/fstab.conf` and `profile/airootfs/etc/calamares/modules/users.conf`.
- Maximum allowed surface area: Creation of these two specific Calamares module configuration files.
- Constraints Architect must obey: Ensure configurations adhere to existing NeOS policies (e.g., Btrfs optimizations like `compress=zstd` and `space_cache=v2`).

## PHASE 5 — Delegation Strategy
- Architect builds: Implement `fstab.conf` and `users.conf` Calamares modules.
- Bolt optimizes: Evaluate performance implications of the `fstab.conf` mount options.
- Palette enhances: Stand by.
- Sentinel audits: Verify user group assignments and filesystem mounting safety.
