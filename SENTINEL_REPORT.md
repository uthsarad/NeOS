## Risks Found
A Local Denial of Service (DoS) vulnerability was found in `neos-autoupdate.sh`. The root script calls `notify-send` across a DBus boundary into the user's session without a timeout. A frozen or malicious user session could hang the root process indefinitely.

## Fixes Applied
Wrapped the `sudo -u "$user_name" -- env DBUS_SESSION_BUS_ADDRESS="..." notify-send` call with `timeout 10s` to enforce a strict execution time limit on the outbound IPC call.

## Remaining Attack Surface
The script's input validation and locking mechanisms appear robust. No immediate additional attack surfaces were identified in the modified function.

## Severity Summary
High - A malicious or frozen user could halt the critical system auto-update process.
