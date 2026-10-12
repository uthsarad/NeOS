## Risks Found
- Local DoS vulnerability via user DBus session in profile/airootfs/usr/local/bin/neos-autoupdate.sh where notify-send is called without a timeout.

## Fixes Applied
- Added timeout 10s before notify-send command in notify_users function to prevent hanging the root process.

## Remaining Attack Surface
- None observed in the current context for notify_users.

## Severity Summary
- HIGH
