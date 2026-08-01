# Risk & Priority Report: Validation Halt Concluded and Phase 7 Posture

## Current Risk Assessment
The technical architecture of the NeOS project maintains a highly secure and stable posture. The validation halt has successfully concluded with the resolution of critical validation debt.

**Resolved Risks:**
- **Diagnostic Logging Opacity:** Palette has confirmed that systemd `ProtectSystem=strict` and `ProtectHome=yes` directives do not compromise `journalctl` diagnostic logging visibility for restricted services like `neos-autoupdate.service`.
- **UX Inconsistency:** Phase 6 UX bindings (`Meta+E`, `Meta+D`) in `profile/airootfs/etc/xdg/kglobalshortcutsrc` have passed accessibility and functional testing.
- **Symlink Traversal (CWE-59):** Sentinel has definitively eradicated HIGH-severity symlink traversal vulnerabilities within provisioning scripts (`profile/airootfs/usr/local/bin/neos-desktop-setup`, `profile/airootfs/usr/local/bin/neos-liveuser-setup`) by rigorously enforcing `[ -L ]` conditional checks before modifying user-controlled configurations.
- **Least Privilege Violations:** Sentinel has significantly hardened services by surgically applying `CapabilityBoundingSet` (e.g., `CAP_CHOWN`, `CAP_DAC_OVERRIDE`) and `RestrictAddressFamilies` directives to `neos-liveuser-setup.service`, enforcing least privilege without breaking Calamares user provisioning.
- **Test Subprocess Overhead:** Bolt successfully eliminated repeated fork/exec subshell overhead in verification scripts (`tests/verify_iso_grub.sh`) and virtualization detection by loading configurations into native Bash variables and utilizing native string matching (`[[ "$CONTENT" == *"$STR"* ]]`).
- **Autoupdate Lock File Contention:** Sentinel resolved silent locking failures by proactively appending `/run` to the `ReadWritePaths` directive in `neos-autoupdate.service`, maintaining operational reliability without violating the primary `ProtectSystem=strict` sandbox boundary.

**Emerging Risks (Phase 7):**
1. **PackageKit Privilege Escalation (High Risk):** Moving into App Store UX via KDE Discover introduces the risk of PackageKit or Polkit misconfigurations. If policies are too permissive, unprivileged users could escalate privileges to install arbitrary system-level packages.
2. **Notification Fatigue (Moderate Risk):** Over-notifying users about available rolling-release updates could degrade the "Windows-familiar" UX, leading to update fatigue or user confusion.
3. **Backend Hangs (Moderate Risk):** If the Discover flatpak or PackageKit backends hang during metadata sync, it could cause GUI freezes, severely impacting perceived system stability.

## Priority Selection
**New feature implementation** (Phase 7: App Store and Package Management UX)

## Actionable Mitigation
- **Architect Governance:** Architect is unpaused but restricted strictly to declarative XDG configuration (`profile/packages.x86_64` and `profile/airootfs/etc/xdg/*`). No core system service modifications or installer script changes are authorized.
- **Specialist Directives:**
  - Sentinel must rigorously audit the Discover-PackageKit integration to ensure Polkit policies correctly prompt for system-level package operations.
  - Palette should ensure update notifications are unobtrusive and the Discover UI remains accessible.
