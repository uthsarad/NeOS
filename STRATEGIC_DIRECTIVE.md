# Strategic Directive: Phase 3 Refinement - Privacy & Telemetry UX

## PHASE 1 — Product Alignment Check
- **What is the product trying to become?** A predictable, Windows-familiar Arch Linux environment.
- **Are we building toward that?** Yes, but we missed the "Privacy and telemetry opt-in controls" in the first-boot UX (Phase 3 Roadmap).
- **Are we solving the highest leverage problem?** Adding this control builds user trust and satisfies a critical roadmap requirement before moving to broader feature sets.

## PHASE 2 — Technical Posture Review
- **Is the system stable?** Yes, Phase 8 validations by Bolt, Palette, and Sentinel are fully completed and no critical regressions were found.
- **Is tech debt increasing?** No, the architecture is sound.
- **Are we overbuilding?** We are avoiding backend implementation; only the UX stub is required to prevent scope creep.

## PHASE 3 — Priority Selection
- **Selection:** Refinement of recent feature (First-boot UX / `neos-welcome-app`).
- **Reasoning:** The Strategic Pause is formally lifted as all Phase 8 validations are complete. We will now address the missing telemetry opt-in UX in the welcome application.

## PHASE 4 — Controlled Scope Definition
- **Impacted Files:** `profile/airootfs/usr/local/bin/neos-welcome-app`
- **Maximum Allowed Surface Area:** Only the PyQt6 welcome application UI.
- **Constraints:**
  1. Add a visual toggle, checkbox, or button for "Telemetry / Privacy Opt-in".
  2. Do NOT implement backend data collection. This is strictly a UX refinement.
  3. Keep the styling consistent with the existing dark theme and layout.

## PHASE 5 — Delegation Strategy
- **Architect:** Implement the PyQt6 UI updates for the telemetry opt-in stub.
- **Bolt:** Monitor `neos-welcome-app` startup performance for any degradation.
- **Palette:** Verify the accessibility, tab order, and color contrast of the new UI controls.
- **Sentinel:** Audit how the opt-in state might be stored (e.g., ensuring no CWE-59 vulnerabilities in temp file usage).
