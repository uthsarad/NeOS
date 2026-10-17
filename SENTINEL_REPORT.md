## Risks Found
- Local Denial of Service (DoS) vulnerability in profile/airootfs/usr/local/bin/neos-autoupdate.sh. The root process interacts with user-controlled daemons (notify-send over a user's DBus session) without a timeout. A frozen or malicious user session could hang the root process indefinitely.

## Fixes Applied
- Wrapped the sudo -u "$user_name" ... notify-send command with a timeout 10s enforcement in neos-autoupdate.sh to prevent user-space deadlocks from hanging the root-owned update script.

## Remaining Attack Surface
- Minimal remaining risk regarding notification system; IPC calls are now bounded by timeouts, inputs are sanitized, and commands use explicit boundaries.

## Severity Summary
- Severity: Medium
