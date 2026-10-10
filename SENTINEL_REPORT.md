## Risks Found
- **Local DoS via User DBus Session:** The `notify_users` function in `neos-autoupdate.sh` invokes `notify-send` over user DBus sessions. A frozen or malicious user session could hang the root process indefinitely because there was no timeout on the IPC call.

## Fixes Applied
- Added `timeout 10s` to the `sudo -u` call executing `notify-send` in `neos-autoupdate.sh` to enforce a strict execution boundary and prevent hanging.

## Remaining Attack Surface
- System updates depend on `pacman`, which handles its own package signature verification and network security.
- Rollback mechanisms depend on `snapper` integrity.

## Severity Summary
- **Local DoS via DBus:** HIGH
