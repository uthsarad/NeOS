## 2026-10-14 - Local DoS via IPC Timeout
**Vulnerability:** IPC calls to user-controlled DBus sessions without a timeout can lead to a Local DoS if the user session is frozen or malicious.
**Learning:** Root scripts interacting with user daemons without time limits can be stalled by user-controlled processes.
**Prevention:** Always wrap outbound IPC calls to user sessions with a strict timeout (e.g., timeout 10s) to prevent hanging the root process.
