# Strategic Directive

## PHASE 1: Product Alignment Check
- What is the product trying to become? NeOS is a curated Arch Linux distribution delivering Windows-level usability with Linux-level power.
- Are we building toward that? Yes, by progressing through the roadmap phases.
- Are we solving the highest leverage problem? The beta release is now published. We need to begin work on Phase 3 (Installer and First-Boot UX).

## PHASE 2: Technical Posture Review
- Is the system stable? Core build is stable, and test infrastructure is robust.
- Is tech debt increasing? No.
- Are we overbuilding? No.

## PHASE 3: Priority Selection
- New feature implementation (Phase 3: Installer UX)

## PHASE 4: Controlled Scope Definition
- Exact files likely impacted: Calamares config (`profile/airootfs/etc/calamares/settings.conf`) or `neos-installer-partition.sh`.
- Maximum allowed surface area: Installer configuration and related scripts.
- Constraints Architect must obey: Focus on simplifying the installer flow for standard users (e.g., sensible defaults, Windows-like layout).

## PHASE 5: Delegation Strategy
- Architect: Implement installer defaults and clean up configuration.
- Bolt: Stand by.
- Palette: Ensure installer steps follow standard UX paradigms.
- Sentinel: Stand by.
