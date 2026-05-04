# PALETTE_REPORT.md

## UX/Accessibility Improvements

### Command-Line Interface (CLI) Visual Clarity
To improve the user experience during the OS boot and installation phases, terminal outputs have been enhanced with ANSI escape codes for color, bold formatting, and visual structure.

*   **Error Messaging:** Critical script failures in `neos-installer-partition.sh` now prominently display in bold red (`\e[1m\e[31m`) for immediate visibility. The structured 'How to fix' section provides clear, actionable steps formatted in bold cyan (`\e[1m\e[36m`) to guide administrators directly to resolution paths.
*   **Validation Errors:** Missing, invalid, or actively mounted target device errors are visually highlighted with red indicators and cyan hints for quick user comprehension.
*   **Progress Tracking:** Partitioning milestones now utilize bold cyan step indicators (`[Step X/Y]`) and green progress representations (`[##........] 20%`), enabling users to parse active operational status at a glance.
*   **Hardware Detection:** The `neos-driver-manager` logs now categorize detections visually: AMD processors display in green, Intel in blue, and generic milestones in cyan.

### Calamares Installer Branding
*   **Brand Consistency:** Confirmed that `branding.desc` complies with NeOS brand guidelines, correctly applying the primary blue (`#0078D4`) to the installer sidebar background.

## Remaining Usability Risks
*   **Screen Reader Compatibility in TTY:** While visual colors assist sighted users, text-mode environments (TTY) may not present progress effectively to screen reader setups unless specifically configured.
*   **Progress Bar Integration:** The `/tmp/neos-partition-progress` file handles numeric output, but deeper integration directly into the Calamares graphical UI via DBus would present a more seamless visual experience.

## 2026-05-03 - Autoupdate UX Improvements
- **Actionable Error Notifications:** Extracted the graphical `notify-send` error logic into a reusable `notify_users` function in `profile/airootfs/usr/local/bin/neos-autoupdate.sh`.
- **Dependency Failure Clarity:** Updated the background dependency check to surface an explicit, actionable graphical error message ("Required command '$cmd' not found. Please install...") instead of silently exiting or only logging to `/var/log`.
- **Unified Error Handling:** Reduced boilerplate and ensured that users are consistently informed of both disk space and missing dependency issues via desktop notifications.

## 2026-06-28 - Autoupdate UX Improvements (Phase 2)
- **Missing Snapper Clarity:** Improved error visibility in `neos-autoupdate.sh` by ensuring the absence of the `snapper` utility invokes `notify_users`, ensuring GUI environments present actionable warnings to users rather than failing silently in the background logs.
- **Update Failure Clarity:** Improved error visibility in `neos-autoupdate.sh` by ensuring pacman update failures invoke `notify_users`, ensuring GUI environments present actionable warnings to users rather than failing silently in the background logs.
