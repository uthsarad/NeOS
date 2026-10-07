## 2026-10-07 - Prevent Root Script Freeze via User DBus Manipulation
**Vulnerability:** A local Denial of Service (DoS) where a malicious user can block system-wide auto-updates by freezing their DBus session daemon. `notify-send` (running via `sudo`) waits indefinitely, hanging the parent `neos-autoupdate.sh` script (which holds a global lock).
**Learning:** When a root script interacts with user-controlled daemons (like DBus via `notify-send`), the user process can manipulate the IPC mechanism to hang the root process.
**Prevention:** Always wrap outbound IPC calls to user sessions (like `notify-send`) with a strict `timeout` when executed from critical root background services.
