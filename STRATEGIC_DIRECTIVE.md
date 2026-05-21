# Strategic Directive: Phase 5 Application & Update UX (Focus on Security Scanning)

## Objective
The primary objective of this cycle is to implement Security Scanning in the CI/CD pipeline. This aligns with Phase 5 of our roadmap (Application & Update UX - System Hardening).

## Context
Based on `docs/AUDIT_ACTION_PLAN.md`, critical and high-priority items have been addressed. The system is stable enough to proceed with medium-priority infrastructure improvements. Item 14 ("Add Security Scanning") is the next logical step to ensure long-term stability and security of the repository.

## Directives
- **Focus:** Integrate automated security scanning into the CI pipeline.
- **Constraints:** Do not modify core system behavior. Limit changes to CI configuration (`.github/workflows/build-iso.yml`) and documentation.
- **Goal:** Add ShellCheck for bash scripts and Trivy for container/ISO scanning.
