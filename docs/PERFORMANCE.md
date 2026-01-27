# NeOS Performance Standards

Speed is a feature. To successfully replace existing operating systems, NeOS must be measurably faster and more responsive. This document defines the performance budgets and optimization strategies for the project.

## ⚡ Performance Budgets

These targets apply to the "Stable" release channel on reference hardware (Modern x86-64, SSD, 8GB+ RAM).

| Metric | Target | Hard Limit | Notes |
| :--- | :--- | :--- | :--- |
| **Cold Boot Time** | < 10s | 15s | From bootloader to lock screen. |
| **Login to Desktop** | < 3s | 5s | From password entry to usable desktop. |
| **Idle RAM Usage** | < 800MB | 1.2GB | Post-boot with no user apps open. |
| **ISO Size** | < 2.5GB | 4GB | Critical for download speed and USB writing. |
| **Installation Time** | < 5m | 10m | Automated install flow on SSD. |

## 🔧 Optimization Strategies

### Base System (Arch Linux)
- **Kernel:** Evaluate `linux-zen` for better desktop interactive performance.
- **I/O Scheduler:** Ensure `bfq` or `kyber` is active for NVMe/SSD.
- **Boot Process:**
  - Minimize `systemd-analyze` critical chain.
  - Disable unused services (e.g., `lvm2-monitor` if not using LVM, printer spools if no printer).

### Desktop Environment (KDE Plasma)
- **Animations:** Default animation speed scale set to instant or fast.
- **Indexing:** Configure Baloo (file indexer) to exclude build directories and sensitive paths, or run only on AC power.
- **Start-up:** Disable "Restore previous session" by default to ensure clean, fast boots.

### Application Layer
- **Preloading:** Use speculative preloading for the default browser (Brave) and File Manager (Dolphin) if RAM permits.
- **Updates:** Run `checkupdates` in a low-priority background process to avoid blocking interactive usage.

## 📏 Measurement Tools

To verify these metrics:
1. **Boot Time:** `systemd-analyze` and `systemd-analyze blame`.
2. **RAM:** `free -h` or `htop`.
3. **Graphics:** `glxgears` is not a benchmark; use real-world application launch profiling.

> **Bolt's Maxim:** "Measure first, optimize second. Don't sacrifice readability for micro-optimizations."
