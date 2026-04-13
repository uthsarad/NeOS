# STRATEGIC_DIRECTIVE

PHASE 1 — Product Alignment Check
- What is the product trying to become?
NeOS aims to be a curated Arch-based desktop OS targeting predictable behavior, delivering a Windows-familiar KDE Plasma experience with low-friction onboarding and long-term stability.
- Are we building toward that?
Yes. Recent efforts have fortified the foundation, adding deep audits, CI validations, robust automated snapshot update mechanisms, and essential installer (Calamares) refinements.
- Are we solving the highest leverage problem?
Currently, our primary focus has been Phase 1/Phase 2 (ISO Build and Foundation). The roadmap indicates Phase 3 targets "Installer and First-Boot UX" including Calamares customization. However, looking at the recent `ARCHITECT_REPORT.md` and `docs/ROADMAP.md`, we need to transition towards improving the first-boot experience. Specifically, addressing the Calamares customization and first-boot wizard. Looking at `docs/AUDIT_ACTION_PLAN.md`, an outstanding high priority item is to "Document Architecture Limitations" which clarifies that Calamares and snapshots are only for x86_64. We will focus on the "Document Architecture Limitations" to set expectations right for Phase 3 and Phase 4, reducing user confusion and support burden.

PHASE 2 — Technical Posture Review
- Is the system stable?
Yes, core validations pass. The ISO builds correctly with profile checks succeeding. Hardening configurations are in place.
- Is tech debt increasing?
No. Tech debt is low.
- Are we overbuilding?
No.

PHASE 3 — Priority Selection
- Infrastructure improvement
Update the README.md and HANDBOOK.md to document architecture limitations.

PHASE 4 — Controlled Scope Definition
- Exact files likely impacted:
  - `README.md`
  - `docs/HANDBOOK.md`
- Maximum allowed surface area:
  - Add documentation regarding supported architectures and their limitations (x86_64 vs i686/aarch64).
- Constraints Architect must obey:
  - Do not alter build scripts or workflows.
  - Limit documentation to clarifying that Calamares installer, snapshot-based updates, and ZRAM compression are only available on x86_64.

PHASE 5 — Delegation Strategy
- Architect builds:
  - Update `README.md` and `docs/HANDBOOK.md` with "Supported Architectures" sections.
- Bolt optimizes:
  - Monitor documentation updates to ensure no heavy assets are added that could bloat the repository or ISO size.
- Palette enhances:
  - Ensure the documentation additions are well-structured, easy to read, and clearly highlight the limitations using appropriate markdown formatting.
- Sentinel audits:
  - Ensure no sensitive URLs, internal IPs, or credentials are leaked in the documentation updates.
