# Strategic Directive

## PHASE 1 — Product Alignment Check
- What is the product trying to become? NeOS aims to be a curated Arch Linux distribution delivering Windows-level usability with Linux-level power.
- Are we building toward that? Yes, the baseline engineering hygiene is strong, but the CI pipeline lacks ISO size validations and complete YAML linting coverage.
- Are we solving the highest leverage problem? Currently, the highest leverage problem is adding ISO size validation, and installing PyYAML to ensure proper YAML validation.

## PHASE 2 — Technical Posture Review
- Is the system stable? Yes, the core builds and basic validations pass. The deep audit confirms no active build-blocking config issues.
- Is tech debt increasing? No, but tooling gaps exist in the CI pipeline.
- Are we overbuilding? No.

## PHASE 3 — Priority Selection
- Infrastructure improvement

## PHASE 4 — Controlled Scope Definition
- Exact files likely impacted: `.github/workflows/build-iso.yml`.
- Maximum allowed surface area: CI pipeline workflows and testing dependencies.
- Constraints Architect must obey: Only add the specified ISO size validation logic and PyYAML dependency; do not alter other pipeline functionality.

## PHASE 5 — Delegation Strategy
- Architect builds: Add ISO size validation to `.github/workflows/build-iso.yml` and add PyYAML to the test environment.
- Bolt optimizes: Nothing.
- Palette enhances: Nothing.
- Sentinel audits: Nothing.
