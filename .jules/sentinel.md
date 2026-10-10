## 2026-10-10 - Local DoS via DBus IPC Timeout
**Vulnerability:** Root scripts interacting with user-controlled daemons (like executing notify-send over a user's DBus session) without a strict timeout can lead to a Local Denial of Service (DoS) if the user session is frozen or maliciously configured to hang the root process.
**Learning:** Always assume user-level IPC mechanisms can hang indefinitely.
**Prevention:** Wrap outbound IPC calls from root to user sessions with a strict timeout (e.g., timeout 10s).
