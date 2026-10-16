## 2026-10-16 - Root Process Hang via DBus IPC (Local DoS)
**Vulnerability:** The root-owned auto-update script was invoking `notify-send` across a user's DBus session without a timeout. A frozen or malicious user session could hang the DBus call, blocking the root script indefinitely and preventing system updates (Local DoS).
**Learning:** Outbound IPC calls from a privileged process to a user-controlled daemon cross a trust boundary and are susceptible to resource exhaustion or indefinite hangs.
**Prevention:** Always wrap outbound IPC calls to user sessions (like `notify-send` over DBus) with a strict timeout (e.g., `timeout 10s`) to ensure the root process recovers execution flow.
