# NeOS Performance Standards

[← Back to Documentation Index](../README.md#documentation)

Speed is a feature. To successfully replace existing operating systems, NeOS must be measurably faster and more responsive. This document defines the performance budgets and optimization strategies for the project.

## Table of Contents
- [Performance Budgets](#performance-budgets)
- [Optimization Strategies](#optimization-strategies)
- [Measurement & Verification](#measurement--verification)

## Performance Budgets

These targets apply to the "Stable" release channel on reference hardware (Modern x86-64, SSD, 8GB+ RAM).

| Metric | Target | Hard Limit | Notes |
| :--- | :--- | :--- | :--- |
| **Cold Boot Time** | < 10s | 15s | From bootloader to lock screen. |
| **Login to Desktop** | < 3s | 5s | From password entry to usable desktop. |
| **Idle RAM Usage** | < 800MB | 1.2GB | Post-boot with no user apps open. |
| **ISO Size** | < 2.5GB | 4GB | Download speed, USB writing and live-session RAM. Not an enforced gate — releases ship via SourceForge, so this is a design target only. |
| **Installation Time** | < 5m | 10m | Automated install flow on SSD. |

## Optimization Strategies

### Base System (Arch Linux)
- **Kernel:** Ship `linux-lts` for hardware/driver stability and predictable DKMS module compatibility (see [ADR 0001](../decisions/0001-linux-lts.md)).
- **Memory & Swap:** Configure `zram-generator` (`zstd`, `ram / 2`) paired with `vm.swappiness = 100` and `vm.page-cluster = 0` (`99-neos-performance.conf`).
- **I/O Scheduler (`60-neos-ioschedulers.rules`):** Set `none` on NVMe SSDs, `mq-deadline` on non-rotational SATA/SAS SSDs, and `bfq` on rotational HDDs.
- **Boot Process:**
  - Minimize `systemd-analyze` critical chain.
  - Gate hypervisor guest agents (`qemu-guest-agent`, `vboxservice`, `vmtoolsd`, `spice-vdagentd`) on `ConditionVirtualization=` so bare-metal boots pay zero guest-agent cost.

### Desktop Environment (KDE Plasma)
- **Animations:** Responsive defaults on Plasma 6 Wayland (with automatic Xfce X11 fallback on software-rendered VMs).
- **Indexing:** Run `plocate-updatedb` only on AC power (`plocate-updatedb.service.d/ac-only.conf`).
- **Start-up:** Keep session startup lean and avoid unnecessary background daemons.

### Application Layer
- **Default Applications:** Ship Firefox (`firefox`) and Dolphin (`dolphin`) with responsive defaults.
- **Updates:** Run `neos-autoupdate.timer` with paired Btrfs Snapper pre/post snapshots in the background.

## Measurement & Verification

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

> **Note:** Measure first, optimize second. Don't sacrifice readability for micro-optimizations.
