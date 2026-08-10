# Strategic Directive: Phase 8 - Legal & Licensing

## Alignment Check
The product roadmap specifies Phase 8 as targeting "Long-Term Maintenance and Distribution." We have completed the foundational operations hub features, crash reporting, and snapshot queries. The final missing piece of Phase 8 is "Legal and licensing - Compliance with upstream licenses and redistribution rules."

## Technical Posture
The system is stable. Sentinel has completed the audit of the snapshot query mechanisms, finding no command injection vulnerabilities and confirming the strategic pause. The core system is ready for the next iteration.

## Priority Selection
We will focus on **New feature implementation** to complete the Phase 8 requirements. Specifically, we need a way for users to view system licensing information natively within the OS.

## Action Plan
We will lift the Strategic Pause. The Architect is directed to implement a "View System Licensing" option within the `neos-operations-hub` script. This option should provide a clear, accessible way to view the primary OS license (MIT) and acknowledge upstream Arch Linux licenses.
