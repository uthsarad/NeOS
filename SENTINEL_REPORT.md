## Risks Found
- Local Denial of Service (DoS) risk in neos-autoupdate.sh. The root script executes notify-send over user-controlled DBus sessions without a timeout, allowing a malicious or frozen user session to hang the root auto-updater process indefinitely.

## Fixes Applied
- Wrapped the outbound notify-send IPC call in profile/airootfs/usr/local/bin/neos-autoupdate.sh with a strict timeout 10s enforcement.

## Remaining Attack Surface
- Minimal remaining risk related to this specific IPC call.

## Severity Summary
- Medium
