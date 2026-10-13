## 2026-10-13 - [Local DoS via DBus IPC]
**Vulnerability:** Root scripts executing outbound IPC calls (like notify-send) over a user-controlled DBus session without timeouts can hang the root process if the user session is frozen or malicious.
**Learning:** Outbound IPC to user daemons from a root context inherently crosses a trust boundary and requires execution limits to avoid Denial of Service.
**Prevention:** Always wrap outbound IPC calls to user sessions with a strict timeout (e.g., timeout 10s).
