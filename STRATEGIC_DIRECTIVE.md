# STRATEGIC DIRECTIVE: Systemd Sandboxing & Stabilization

## Phase 1: Product Alignment Check
- **Goal:** NeOS is a curated, stable, and secure Arch Linux desktop.
- **Current State:** A core feature, snapshot-based rollback and secure defaults, is mostly in place. We are currently addressing audit findings to ensure we don't ship vulnerable configurations.
- **Alignment:** Prioritizing hardening directly serves the product's "predictable and secure" mission.

## Phase 2: Technical Posture Review
- **Stability:** The build pipeline and primary services are stable and pass automated testing.
- **Tech Debt:** An outstanding medium-priority audit item (#7) identifies incomplete systemd sandboxing across services. `neos-driver-manager.service` has been hardened, but `neos-autoupdate.service` and `neos-liveuser-setup.service` are missing critical sandboxing directives.
- **Overbuilding:** No. Implementing documented, missing security constraints is a straightforward stabilization task.

## Phase 3: Priority Selection
- **Selected:** Stabilization / hardening
- **Justification:** Completing the systemd sandboxing closes an open audit loop, tightening root-level execution environments and reducing the risk of privilege escalation.

## Phase 4: Controlled Scope Definition
- `profile/airootfs/etc/systemd/system/neos-autoupdate.service`
- `profile/airootfs/etc/systemd/system/neos-liveuser-setup.service`
- `docs/AUDIT_ACTION_PLAN.md` (to update checklist status)
- **Constraints:** Do NOT modify `neos-driver-manager.service` as it already conforms to sandboxing tests. Do NOT break update functionality by using overly restrictive protections in `neos-autoupdate.service` (e.g., `ProtectSystem=strict` should be avoided there if it breaks updates).

## Phase 5: Delegation Strategy
- **Architect:** Implement systemd sandboxing for `neos-autoupdate.service` and `neos-liveuser-setup.service` as outlined in `docs/AUDIT_ACTION_PLAN.md`. Update the audit documentation tracking.
- **Bolt:** Validate that the new sandboxing rules do not measurably slow down service boot times.
- **Palette:** Ensure any failures due to sandboxing produce clear, actionable log outputs.
- **Sentinel:** Audit the sandboxing rules to ensure they effectively mitigate risk without breaking intended service behavior.