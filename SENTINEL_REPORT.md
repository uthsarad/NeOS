## Risks Found
- **Denial of Service (DoS):** The `neos-autoupdate.sh` script executes `notify-send` across user DBus sessions while holding a global `flock`. A malicious user can freeze their DBus daemon, causing `notify-send` to hang indefinitely, blocking all future system updates.

## Fixes Applied
- Added a `timeout 10s` wrapper to the `notify-send` execution in `notify_users` within `profile/airootfs/usr/local/bin/neos-autoupdate.sh`.

## Remaining Attack Surface
- The script still relies on external binaries (`pacman`, `snapper`, `notify-send`, etc.). While inputs are sanitized, robust privilege separation for the update process itself remains an area for future hardening.

## Severity Summary
- **HIGH**: A local user can intentionally block critical system-wide security updates by hanging a background root service.
