# NeOS Performance Standards

Speed is a feature. To successfully replace existing operating systems, NeOS must be measurably faster and more responsive. This document defines the performance budgets and optimization strategies for the project.

## Table of Contents
- [Performance Budgets](#-performance-budgets)
- [Optimization Strategies](#-optimization-strategies)
- [Measurement & Verification](#-measurement--verification)

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

## 📏 Measurement & Verification

Use these commands to verify the performance budgets:

### 1. Boot Time
```bash
# Check overall boot time
systemd-analyze

# Find bottleneck services
systemd-analyze blame | head -n 10

# Check critical chain (time blocked)
systemd-analyze critical-chain
```

### 2. Resource Usage
```bash
# Check RAM usage (human readable)
free -h

# Check current I/O scheduler (example for sda)
cat /sys/block/sda/queue/scheduler
```

### 3. Application Performance
Do not use `glxgears`. To profile application launch time (e.g., for Dolphin):
```bash
# Measure time to launch and close immediately
/usr/bin/time -f "%E real,%U user,%S sys" dolphin --version
```

> **Bolt's Maxim:** "Measure first, optimize second. Don't sacrifice readability for micro-optimizations."
