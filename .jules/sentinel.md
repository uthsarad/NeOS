## 2026-10-09 - Local DoS via IPC Hang
**Vulnerability:** Root processes calling user-controlled DBus daemons (like notify-send) can be permanently hung by malicious or frozen user sessions.
**Learning:** Never trust user-controlled IPC endpoints to return in a timely manner. A malicious user can intentionally stall the DBus session, causing the calling root script (e.g., auto-updater) to hang indefinitely.
**Prevention:** Always wrap outbound IPC calls to user sessions with a strict timeout (e.g., timeout 10s) to enforce execution limits and prevent Local DoS.
