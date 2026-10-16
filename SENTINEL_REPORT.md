## Risks Found
- **Local Denial of Service (DoS):** The `neos-autoupdate.sh` script (running as root) uses `notify-send` to alert users over their DBus session. Without a timeout, a blocked, hanging, or maliciously manipulated user DBus session can hang the entire root update script indefinitely.

## Fixes Applied
- Added a `timeout 10s` wrapper around the `notify-send` invocation in `notify_users()` to ensure the root process regains control if the user's DBus session fails to respond.

## Remaining attack surface
- The script still relies on `notify-send` which executes within the user's environment. While the timeout mitigates a hang, failure of the notification does not retry, meaning users might miss update alerts.
- Btrfs snapshot IDs (`snap_id`) are sanitized but still parsed from standard output, which could technically be manipulated if the `snapper` binary itself is compromised.

## Severity summary
- **Local DoS (DBus Hang):** High priority - Fixed.
