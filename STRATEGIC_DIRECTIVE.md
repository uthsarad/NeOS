# Strategic Directive: Phase 4 Hardware Enablement

## PHASE 1 — Product Alignment Check
- **What is the product trying to become?** A predictable, Windows-familiar Arch Linux environment that "just works" out of the box on common hardware.
- **Are we building toward that?** Yes, by ensuring the baseline hardware detection is secure and performant before proceeding to driver installation.
- **Are we solving the highest leverage problem?** Yes, validating the foundation of hardware enablement is critical before adding complexity.

## PHASE 2 — Technical Posture Review
- **Is the system stable?** The baseline implementation for Nvidia GPU detection is complete, but pending specialist validation.
- **Is tech debt increasing?** No.
- **Are we overbuilding?** No, we are holding the line to ensure quality.

## PHASE 3 — Priority Selection
- **Selection:** No-build day (strategic pause).
- **Reasoning:** Specialist validations (Bolt, Palette, Sentinel) for the Phase 4 Nvidia GPU detection baseline in `neos-hardware-setup` are currently pending. We must halt new feature development until these audits are completed to prevent compounding risk.

## PHASE 4 — Controlled Scope Definition
- **Impacted Files:** None.
- **Maximum Allowed Surface Area:** 0 files (for Architect).
- **Constraints:**
  1. Architect must halt all feature development.
  2. Architect must acknowledge the strategic pause.

## PHASE 5 — Delegation Strategy
- **Architect:** Observe Strategic Pause. Fulfill obligations by documenting the pause in `ARCHITECT_REPORT.md` and appending tasks that formally acknowledge the pause in the specialist task manifests.
- **Bolt:** Execute pending task: Optimize hardware detection logic in `neos-hardware-setup`.
- **Palette:** Execute pending task: Standby for Phase 4 UI implementations.
- **Sentinel:** Execute pending task: Audit hardware detection script to ensure parsing of PCI output does not introduce command injection risks.
