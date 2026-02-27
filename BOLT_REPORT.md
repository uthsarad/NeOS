# BOLT_REPORT

## ⚡ Optimization: TCP Latency & Throughput Tuning

### 💡 What
Added two key TCP stack optimizations to `airootfs/etc/sysctl.d/99-neos-performance.conf`:
1.  `net.ipv4.tcp_fastopen = 3`: Enables TCP Fast Open (TFO) for both incoming and outgoing connections.
2.  `net.ipv4.tcp_slow_start_after_idle = 0`: Disables the behavior where TCP congestion windows reset to slow-start defaults after an idle period.

### 🎯 Why
-   **TCP Fast Open:** Reduces network latency by allowing data to be carried in the SYN packet during the initial TCP handshake. This saves one full Round Trip Time (RTT) for repeated connections to TFO-enabled servers (common in modern web services).
-   **Slow Start After Idle:** Standard TCP resets the congestion window (CWND) after the connection is idle, treating it as a new connection. For persistent connections (like HTTP/2, SSH, or long-polling), this causes unnecessary throttling and "ramp up" time when activity resumes. Disabling this (`=0`) maintains the high-speed window, ensuring immediate throughput availability.

### 📊 Impact
-   **Latency:** Up to 1 RTT saving on connection establishment for supported services.
-   **Throughput:** Eliminates bandwidth "ramp up" delays on persistent idle connections, making the desktop experience (web browsing, API polling) feel snappier.
-   **Efficiency:** Better utilization of the BBR congestion control algorithm already enabled in the configuration.

### 🔬 Measurement
Verified using `tests/verify_performance_config.sh`, which asserts that:
-   `net.ipv4.tcp_fastopen` is explicitly set to `3`.
-   `net.ipv4.tcp_slow_start_after_idle` is explicitly set to `0`.

These settings are standard best practices for modern low-latency networks and are widely deployed in server and desktop performance tuning guides (e.g., Google BBR, Arch Wiki).
