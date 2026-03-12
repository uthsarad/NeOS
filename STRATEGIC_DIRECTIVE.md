# Strategic Directive

## Date: 2026-02-17

### Phase 1: Product Alignment Check
The product aims to be a stable, predictable, and Windows-familiar Arch-based operating system. We must solve the highest leverage problems first, which currently are missing critical safeguards identified in the recent audit (`docs/DEEP_AUDIT.md` and `docs/AUDIT_ACTION_PLAN.md`).

### Phase 2: Technical Posture Review
While foundational infrastructure is laid out, the system suffers from technical debt regarding robustness (silent failures in auto-update if dependencies are missing) and missing clarity in documentation regarding supported architectures.

### Phase 3: Priority Selection
**Stabilization / hardening**.
We will address the "High Priority" items from `docs/AUDIT_ACTION_PLAN.md` related to silent failures and user confusion. (Note: ISO size validation was addressed previously).

### Phase 4: Controlled Scope Definition
The Architect is authorized to implement the following:
1.  **Dependency Validation**: Add dependency checks to `airootfs/usr/local/bin/neos-autoupdate.sh` to prevent silent failures.
2.  **Architecture Limitations Documentation**: Update `README.md` and `docs/HANDBOOK.md` to explicitly clarify that x86_64 is the primary tier, and i686/aarch64 lack the Calamares installer, snapshots, and ZRAM features.

**Constraints:**
- No new features.
- No changes to the core build process (`build.sh`, `mkarchiso` configuration).
- The Architect must implement the narrowest possible interpretation of these tasks.

### Phase 5: Delegation Strategy
-   **Architect**: Implement the required checks in `neos-autoupdate.sh` and update documentation.
-   **Bolt**: Ensure new bash checks are performant and use native features where possible.
-   **Palette**: Ensure any logged errors or notifications from `neos-autoupdate.sh` are clear, actionable, and user-friendly. Ensure documentation updates use structured, bulleted lists for readability.
-   **Sentinel**: Verify that dependency checks do not introduce command injection risks or symlink vulnerabilities.
