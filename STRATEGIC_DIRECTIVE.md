# Strategic Directive

## PHASE 1 - Product Alignment Check
- What is the product trying to become? A curated Arch Linux distribution delivering Windows-level usability with Linux-level power.
- Are we building toward that? Yes, by refining the core installation and update experience.
- Are we solving the highest leverage problem? Stabilizing the foundational scripts ensures a reliable baseline for future UX work.

## PHASE 2 - Technical Posture Review
- Is the system stable? Core build scripts and updaters are functional but require hardening.
- Is tech debt increasing? Minor unoptimized areas in build caching and missing security boundaries in update scripts.
- Are we overbuilding? No, we are focusing on hardening existing components.

## PHASE 3 - Priority Selection
Selection: Stabilization / hardening. Focus will be placed on securing the automated update mechanism, optimizing the build pipeline, and refining the first-boot experience.

## PHASE 4 - Controlled Scope Definition
- Exact files likely impacted: build.sh, profile/airootfs/usr/local/bin/neos-welcome-app, profile/airootfs/usr/local/bin/neos-autoupdate.sh.
- Maximum allowed surface area: Core shell scripts and Python UX applications.
- Constraints Architect must obey: Do not introduce new features. Ensure all modifications strictly improve security, accessibility, or performance.

## PHASE 5 - Delegation Strategy
- Architect builds: Stabilization patches for the build and update workflows.
- Bolt optimizes: build.sh package caching and pipeline execution.
- Palette enhances: profile/airootfs/usr/local/bin/neos-welcome-app accessibility and readability.
- Sentinel audits: profile/airootfs/usr/local/bin/neos-autoupdate.sh for secure file handling and privilege escalation risks.
