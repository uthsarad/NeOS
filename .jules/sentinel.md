## 2026-10-17 - Root IPC Local DoS Vulnerability
**Vulnerability:** Root script neos-autoupdate.sh interacts with user-controlled DBus daemons (via notify-send) without a timeout.
**Learning:** A frozen or malicious user session could hang the root process indefinitely.
**Prevention:** Always wrap outbound IPC calls to user sessions with a strict timeout (e.g., timeout 10s) to prevent a Local DoS.
