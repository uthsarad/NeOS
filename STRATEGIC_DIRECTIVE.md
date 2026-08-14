# Strategic Directive: Phase 4 Hardware Enablement

## PHASE 1 — Product Alignment Check
- **What is the product trying to become?** A predictable, Windows-familiar Arch Linux environment that "just works" out of the box on common hardware.
- **Are we building toward that?** Yes, moving to Phase 4 focuses on seamless hardware handling.
- **Are we solving the highest leverage problem?** Yes, out-of-the-box Nvidia driver support is critical for adoption and stability on desktop systems.

## PHASE 2 — Technical Posture Review
- **Is the system stable?** Yes, specialist validations for the previous Phase 3 features have successfully completed.
- **Is tech debt increasing?** No.
- **Are we overbuilding?** We are starting small. The first step is simply detecting Nvidia hardware, not full driver installation.

## PHASE 3 — Priority Selection
- **Selection:** New feature implementation.
- **Reasoning:** Phase 3 validations are clear. We are advancing to Phase 4, targeting Nvidia driver automation.

## PHASE 4 — Controlled Scope Definition
- **Impacted Files:** A new file to handle hardware setup.
- **Maximum Allowed Surface Area:** 1 file.
- **Constraints:**
  1. Architect must only implement the initial hardware detection logic (specifically targeting Nvidia GPUs).
  2. Architect must not implement any driver installation mechanisms (e.g., pacman calls) yet.
  3. Provide clear console output of the detection results.

## PHASE 5 — Delegation Strategy
- **Architect:** Implement baseline Nvidia GPU detection in a new hardware setup script.
- **Bolt:** Optimize PCI detection tools to minimize subprocess overhead.
- **Palette:** Standby. No GUI changes in this baseline.
- **Sentinel:** Audit the detection script for command injection or arbitrary execution vulnerabilities.
