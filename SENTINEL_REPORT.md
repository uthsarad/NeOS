## Risks Found
- Local Denial of Service (DoS): A root process calling `notify-send` over a user's DBus session can hang indefinitely if the user session is frozen or maliciously altered.

## Fixes Applied
- Added a `timeout 10s` wrapper around the `sudo ... notify-send` command in `profile/airootfs/usr/local/bin/neos-autoupdate.sh` to enforce a strict timeout on the outbound IPC call.

## Remaining Attack Surface
- Users may still miss notifications if their session is frozen, but this no longer affects system update operations or root processes.
- DBus session availability depends on user configuration and is unauthenticated against the notification daemon beyond standard user permissions.

## Severity Summary
- **Critical:** 0
- **High:** 0
- **Medium:** 1 (Local DoS via DBus IPC)
- **Low:** 0
