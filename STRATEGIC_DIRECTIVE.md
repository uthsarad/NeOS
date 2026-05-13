# STRATEGIC DIRECTIVE: ISO Boot Verification in Virtual Environment

## Phase 1: Product Alignment
NeOS must deliver a reliable out-of-the-box experience. A successful ISO build is insufficient if the resulting image fails to boot or operate correctly in common environments. Verifying the ISO boot process directly supports the mission of delivering a stable, predictable foundation for users.

## Phase 2: Technical Posture
The project has achieved a stable build pipeline and resolved critical configuration blockers. However, the `AUDIT_ACTION_PLAN.md` identifies "[ ] **CRITICAL:** Test ISO boots in VM" as an outstanding, high-risk item that must be addressed before beta release. The infrastructure exists to build the ISO, but end-to-end runtime validation is currently missing from the automated pipeline or documented manual processes.

## Phase 3: Priority Selection
Selected Priority: **Stabilization / hardening**. Ensuring the generated artifact is actually usable is paramount. Addressing the untested ISO boot risk directly targets the highest remaining critical item in the audit plan.

## Phase 4: Controlled Scope
- **Impacted Files:** `tests/verify_iso_smoketest.sh`, `.github/workflows/build-iso.yml`, `docs/AUDIT_ACTION_PLAN.md`
- **Allowed Action:** Enhance the existing ISO smoke test script to utilize QEMU for a basic boot verification if an ISO is present, or document the manual VM testing procedure if automation is out of scope for the current environment. Update the audit checklist upon successful implementation.
- **Constraints:** Do not introduce heavy dependencies (like full GUI testing frameworks) that exceed the current CI runner capabilities without explicit justification. Ensure the test degrades gracefully if virtualization is unavailable.

## Phase 5: Delegation Strategy
- **Architect:** Implement the automated QEMU-based boot validation in `tests/verify_iso_smoketest.sh` or create the manual testing documentation.
- **Bolt:** Ensure any automated boot test completes within a reasonable timeout to prevent CI hangs.
- **Palette:** No direct UI/UX changes required, but ensure any test failure logs are clearly legible.
- **Sentinel:** Verify that running QEMU in CI does not introduce privilege escalation risks or expose the runner to untrusted code execution.
