## 2026-10-11 - DBus IPC Local DoS Risk
**Vulnerability:** The root autoupdate script invoked notify-send across a user-controlled DBus session boundary without a timeout, allowing a malicious or frozen user session to hang the root process indefinitely (Local DoS).
**Learning:** Outbound IPC calls to lower-privileged user boundaries must always be treated as untrusted and potentially blocking.
**Prevention:** Always wrap outbound IPC calls to user daemons with strict timeouts (e.g., timeout 10s).
