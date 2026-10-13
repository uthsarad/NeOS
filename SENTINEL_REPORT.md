## Risks Found
- **High Risk**: A Local Denial of Service (DoS) vulnerability existed in `profile/airootfs/usr/local/bin/neos-autoupdate.sh`. The root process executed `notify-send` over user DBus sessions without a timeout, which could cause the root script to hang indefinitely if a user session was malicious or frozen.

## Fixes Applied
- Added `timeout 10s` to the `notify-send` outbound IPC call within the `notify_users` function to enforce a strict execution bound and prevent hanging the root process.

## Remaining attack surface
- The script continues to interact with user sessions to display notifications, but the impact of any user-side delay is now strictly bound by the 10-second timeout.
- Other external command executions (like `pacman` and `snapper`) rely on system state and could hang, though they are outside user control.

## Severity summary
- **High**: The Local DoS risk could have stopped automated critical security updates from completing if an earlier DBus notification hung the autoupdater process.
