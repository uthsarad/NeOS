## 2026-10-15 - Root Process Hang via User DBus Session
**Vulnerability:** A root process calling an outbound IPC method (e.g., notify-send) on a user's DBus session can hang indefinitely if the user session is frozen or malicious, causing a Local DoS.
**Learning:** Outbound IPC calls from root to user domains cross a trust boundary and can block the calling root process.
**Prevention:** Always wrap outbound IPC calls with a strict timeout (e.g., timeout 10s) to prevent blocking the root process.
