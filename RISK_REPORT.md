# Risk & Priority Report: Phase 7 Validation Halt

## Current Risk Assessment
The technical architecture of the NeOS project maintains a highly secure and stable posture. The validation halt for Phase 6 has successfully concluded with the resolution of critical validation debt. However, Architect has implemented the baseline configuration for Phase 7 (App Store UX), introducing `discover`, `packagekit-qt6`, `flatpak`, and `fwupd` to `profile/packages.x86_64` and creating `profile/airootfs/etc/xdg/discoverrc`. This introduces significant new attack surfaces and potential performance bottlenecks that must be validated.

**Resolved Risks:**
- **Diagnostic Logging Opacity:** Palette has confirmed that systemd `ProtectSystem=strict` and `ProtectHome=yes` directives do not compromise `journalctl` diagnostic logging visibility for restricted services like `neos-autoupdate.service`.
- **UX Inconsistency:** Phase 6 UX bindings (`Meta+E`, `Meta+D`) in `profile/airootfs/etc/xdg/kglobalshortcutsrc` have passed accessibility and functional testing.
- **Symlink Traversal (CWE-59):** Sentinel has definitively eradicated HIGH-severity symlink traversal vulnerabilities within provisioning scripts (`profile/airootfs/usr/local/bin/neos-desktop-setup`, `profile/airootfs/usr/local/bin/neos-liveuser-setup`) by rigorously enforcing `[ -L ]` conditional checks before modifying user-controlled configurations.
- **Least Privilege Violations:** Sentinel has significantly hardened services by surgically applying `CapabilityBoundingSet` (e.g., `CAP_CHOWN`, `CAP_DAC_OVERRIDE`) and `RestrictAddressFamilies` directives to `neos-liveuser-setup.service`, enforcing least privilege without breaking Calamares user provisioning.
- **Test Subprocess Overhead:** Bolt successfully eliminated repeated fork/exec subshell overhead in verification scripts (`tests/verify_iso_grub.sh`) and virtualization detection by loading configurations into native Bash variables and utilizing native string matching (`[[ "$CONTENT" == *"$STR"* ]]`).
- **Autoupdate Lock File Contention:** Sentinel resolved silent locking failures by proactively appending `/run` to the `ReadWritePaths` directive in `neos-autoupdate.service`, maintaining operational reliability without violating the primary `ProtectSystem=strict` sandbox boundary.

**Emerging Risks (Phase 7):**
1. **PackageKit Privilege Escalation (High Risk):** KDE Discover interfaces with PackageKit and Polkit. If the default policies are too permissive, unprivileged live session users could escalate privileges to install arbitrary system-level packages. This is a critical risk that must be definitively mitigated.
2. **Backend Hangs & Blocking Subprocesses (Moderate Risk):** If the Discover `flatpak` or `fwupd` backends hang during metadata sync, it could cause GUI freezes, severely impacting perceived system stability and Plasma startup performance.
3. **Notification Fatigue & UX Regression (Moderate Risk):** Over-notifying users about available rolling-release updates could degrade the "Windows-familiar" UX.

## Priority Selection
**No-build day (strategic pause)**

## Actionable Mitigation
- **Architect Governance:** Enforce a strict "Strategic Pause" (`forbidden_files: ["**/*"]`). Architect is not authorized to implement any production code or configuration changes during this cycle.
- **Specialist Directives:**
  - **Sentinel:** Must clear the pending audit of `packagekit-qt6` privilege contexts and verify Polkit rules.
  - **Bolt:** Must clear the pending performance evaluation of Discover backend initialization in `profile/airootfs/etc/xdg/discoverrc`.
  - **Palette:** Must clear the pending UX consistency review of the Discover app center configuration.

## Phase 7 Validation Update

### Current Risk Assessment
The system's technical posture has improved as Phase 7 App Store validations progress. The critical HIGH risk concerning PackageKit privilege escalation has been resolved by Sentinel through the implementation of strict Polkit rules (`50-neos-packagekit.rules`).

**Resolved Risks:**
- **PackageKit Privilege Escalation (High Risk):** Sentinel successfully enforced `AUTH_ADMIN` for sensitive PackageKit operations, mitigating the risk of unprivileged system modification.
- **Backend Hangs & Blocking Subprocesses (Moderate Risk):** Bolt optimized the Discover configuration verification scripts and monitored startup performance, confirming no blocking subprocesses.

**Emerging Risks (Phase 7):**
1. **Unresolved UX Inconsistency (Moderate Risk):** Palette has not yet completed the pending task to enhance Discover UI/UX accessibility and update notifications in `discoverrc`. Notification fatigue remains a risk for the "Windows-familiar" goal.

### Priority Selection
- No-build day (strategic pause)

### Actionable Mitigation
- **Architect Governance:** Enforce a strict "Strategic Pause" (`forbidden_files: ["**/*"]`). Architect must not modify any production code until Phase 7 validation is completely cleared.
- **Specialist Directives:**
  - **Palette:** Must clear the pending UX consistency review of the Discover app center configuration.
  - **Sentinel:** Standby.
  - **Bolt:** Standby.
