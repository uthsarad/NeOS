## 2026-10-08 - Local DoS via User DBus Session Hang
**Vulnerability:** Root scripts interacting with user-controlled daemons (e.g. notify-send over DBus) can be hung by a frozen or malicious user session, causing a Local Denial of Service (DoS) for the root process.
**Learning:** Outbound IPC calls from root to user sessions must never block indefinitely. Trust boundaries apply not just to input data, but to execution time and state synchronization.
**Prevention:** Always wrap outbound IPC calls crossing privilege boundaries with a strict timeout (e.g. timeout 10s) to guarantee the parent root process can continue execution.
