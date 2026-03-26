# Palette UX/Developer Experience Report

## Improvements Made
- **Clearer Error Messaging in `neos-autoupdate.sh`:** Updated the log message generated when the `snapper` dependency is missing. The message was changed from a generic "ERROR" to a clearer "WARNING" that explicitly explains *why* the process was stopped (to prevent modifications without a rollback snapshot) and provides actionable context on *how* to resolve the issue (`pacman -S snapper`). This provides significantly better developer/admin UX.

## Remaining Usability Risks
- The `notify-send` failure block relies heavily on D-Bus environment variables, which might not be set properly for all session types (e.g., bare TTYs without `loginctl` configurations).
