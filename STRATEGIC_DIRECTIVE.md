# Maestro Strategic Directive

## PHASE 1 — Product Alignment Check
- **What is the product trying to become?** A predictable, Windows-familiar Arch-based distribution prioritizing stability via snapshot infrastructure.
- **Are we building toward that?** Yes, but documentation trails capabilities. Experimental architecture usage generates expectation mismatches.
- **Are we solving the highest leverage problem?** Yes. Clarifying supported vs. experimental architectures directly reduces support burden and clarifies the project's reliability boundaries.

## PHASE 2 — Technical Posture Review
- **Is the system stable?** The x86_64 core is stabilizing. Experimental i686/aarch64 builds lack parity.
- **Is tech debt increasing?** User expectation debt is increasing due to undocumented feature gaps across architectures.
- **Are we overbuilding?** No. This is a documentation refinement.

## PHASE 3 — Priority Selection
- **Priority:** Refinement of recent feature (Documentation).
- **Rationale:** The `AUDIT_ACTION_PLAN.md` specifically calls out "Document Architecture Limitations" as a HIGH priority to mitigate user confusion.

## PHASE 4 — Controlled Scope Definition
- **Exact files likely impacted:** `README.md`
- **Maximum allowed surface area:** 1 file.
- **Constraints Architect must obey:** Update the README to explicitly detail x86_64 as primary and i686/aarch64 as experimental with limited features (no GUI installer, no snapshots, no ZRAM). Do not modify unrelated sections.

## PHASE 5 — Delegation Strategy
- **Architect:** Append architecture support limitations to `README.md`.
- **Bolt:** N/A (Documentation change only).
- **Palette:** Ensure markdown additions use clear headings, lists, and emojis (✅/⚠️) for readability.
- **Sentinel:** Verify no external links are introduced that could pose a security or phishing risk.
