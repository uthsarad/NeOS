## 2026-10-12 - Local DoS via user DBus session
**Vulnerability:** Root script executing user-level IPC command (notify-send) without a timeout.
**Learning:** A frozen or malicious user session can hang the root process indefinitely.
**Prevention:** Always wrap outbound IPC calls to user-controlled daemons with a strict timeout (e.g., timeout 10s).
