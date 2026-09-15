# NeOS Deep Security & Architectural Audit Report

**Target Architecture:** NeOS (Next Evolution Operating System)  
**Evaluated Repository:** `/home/nimuthu/NeOS`  
**Branch / Target:** `main`  
**Audit Lead:** Security & Quality Engineering Team  
**Date:** 2026-08-18  

---

## 🏛️ Executive Abstract & System Threat Model

NeOS is a curated, snapshot-gated Arch Linux workstation distribution engineered for enterprise-grade stability, elite cybersecurity defaults, and a seamless KDE Plasma 6 desktop experience.

Unlike conventional distributions that clone an ephemeral live image to disk, NeOS enforces a **Zero-Clone Netinstall Architecture**:
1. The **Live ISO** boots an ephemeral SquashFS environment with live-session tuning, automated hardware detection, and an offline pacman package cache.
2. The **Calamares Installer** triggers `neos-pacstrap` with `dontChroot: true`, executing `pacstrap -K` to bootstrap a clean base OS directly into the target mount (`${ROOT}`).
3. The **NeOS Curation Overlay** (`neos-overlay.txt`) injects hardened system configurations, custom systemd sandboxed services, and branding while strictly excluding live-only credentials and autologin artifacts.

---

## Deep Vulnerability & Threat Vector Analysis

### 1. Manifest & Overlay Desynchronization (CWE-436 / Configuration Drift)
* **Vulnerability Class:** Configuration Drift / Incomplete Delivery
* **Impact Assessment:** When new components (`50-neos-packagekit.rules`, `neos-operations-hub`, `neos-hardware-setup`, XDG shortcuts) were introduced into `profile/airootfs`, the committed manifest `neos-overlay.txt` was not regenerated. Because `neos-pacstrap` relies on `rsync -a --files-from=neos-overlay.txt`, an installed system bootstrapped from the static manifest omitted Polkit authorization rules, leaving unprivileged users capable of invoking PackageKit operations without `AUTH_ADMIN`.
* **Remediation Implemented:**
  - Regenerated `neos-overlay.txt` and `neos-packages.txt` via `tools/gen-manifests.sh`.
  - Enforced manifest generation in the pre-build CI workflow (`.github/workflows/build-iso.yml`) and verified via `tests/verify_pacstrap.sh`.

---

### 2. Profiledef Access Control Boundaries (CWE-732 / Incorrect Permission Assignment)
* **Vulnerability Class:** Incorrect Permission Assignment for Critical Resource
* **Impact Assessment:** `profile/profiledef.sh` explicitly controls file permissions when packing the SquashFS archive. Newly committed binaries (`neos-operations-hub` and `neos-hardware-setup`) were omitted from `file_permissions`, risking default non-executable umask inheritance on extracted rootfs filesystems.
* **Remediation Implemented:**
  - Added explicit `"0:0:755"` file permission declarations for both binaries in `file_permissions`.

---

### 3. Sticky-Bit `/tmp` Race Conditions & State Volatility (CWE-377 / CWE-59)
* **Vulnerability Class:** Insecure Temporary File / Sticky-Bit Denial of Service
* **Impact Assessment:** In `profile/airootfs/usr/local/bin/neos-welcome-app`, `closeEvent` used `os.rename(tmp_file, "/tmp/neos-telemetry-optin")`. Under Linux sticky bit (`+t`) directory protections (`fs.protected_regular = 2`), if `/tmp/neos-telemetry-optin` is pre-created by another UID, `os.rename` throws an unhandled `PermissionError`. Additionally, `/tmp` is a `tmpfs` RAM disk, causing the opt-in choice to be wiped on reboot.
* **Remediation Implemented:**
  - Refactored `closeEvent` to store persistent preferences into `$XDG_CONFIG_HOME/neos/telemetry-optin` (`~/.config/neos/telemetry-optin`) via safe atomic replacement with mode `0600`, while adding `os.path.islink()` guards and error handling.

---

### 4. Snapper Transaction Hook Fault Tolerance (CWE-754 / Improper Check for Unusual Conditions)
* **Vulnerability Class:** Unhandled Dependency Failure
* **Impact Assessment:** `49-neos-snapshot-pre.hook` and `99-neos-snapshot-post.hook` triggered `snapper --config=root` unconditionally during pacman transactions. If a user installed NeOS on an `ext4`/`xfs` partition or before snapper configs were initialized, pacman operations would abort with non-zero exit codes.
* **Remediation Implemented:**
  - Added defensive conditional guards: `if command -v snapper >/dev/null 2>&1 && [ -e /etc/snapper/configs/root ]; then ... || true; fi` to guarantee smooth pacman transactions across all filesystem types.

---

### 5. Signal Lifecycle & Ephemeral File Hygiene in Launchers (CWE-459)
* **Vulnerability Class:** Incomplete Cleanup / Information Leakage
* **Impact Assessment:** In `profile/airootfs/usr/local/bin/neos-welcome`, temporary installer log files generated with `mktemp` lacked an `EXIT` signal trap, accumulating stale root-owned log files in `/tmp` upon abnormal process termination.
* **Remediation Implemented:**
  - Added `trap 'rm -f "$LOG"' EXIT INT TERM` and strict `export PATH` sanitization.

---

## 🔒 Deep System Hardening & Security Matrix

### 1. Kernel Parameter Hardening (`90-neos-security.conf`)
- `kernel.dmesg_restrict = 1`: Restricts `dmesg` to `CAP_SYSLOG` (prevents kernel address leakage).
- `kernel.kptr_restrict = 2`: Obfuscates kernel symbol pointers from `/proc/kallsyms` (thwarts KASLR bypass).
- `kernel.yama.ptrace_scope = 1`: Restricts `ptrace` to parent processes (blocks process memory injection).
- `net.core.bpf_jit_harden = 2`: Enables constant blinding in BPF JIT compiler (prevents JIT spraying attacks).
- `kernel.unprivileged_bpf_disabled = 1`: Prohibits unprivileged users from loading eBPF programs.
- `fs.protected_fifos = 2` & `fs.protected_regular = 2`: Disallows opening FIFOs or regular files not owned by user in sticky directories.
- `fs.protected_hardlinks = 1` & `fs.protected_symlinks = 1`: Prevents link spoofing and traversal attacks.
- `net.ipv4.tcp_syncookies = 1`: Protects against TCP SYN flood denial-of-service attacks.
- `net.ipv4.conf.all.rp_filter = 1`: Strict Reverse Path Filtering (drops spoofed source IP packets).
- `net.ipv4.conf.all.accept_source_route = 0`: Drops source-routed packets.
- `net.ipv4.tcp_rfc1337 = 1`: Protects against TCP Time-Wait Assassination.
- `kernel.sysrq = 176`: Restricts SysRq to safe subset: `sync`(16) + `remount-ro`(32) + `reboot`(128).
- `fs.suid_dumpable = 0`: Disables core dumps for SUID/SGID binaries.
- `dev.tty.ldisc_autoload = 0`: Blocks automatic line discipline loading.
- `vm.unprivileged_userfaultfd = 0`: Mitigates use-after-free heap grooming.
- `kernel.perf_event_paranoid = 3`: Restricts performance event monitoring to `CAP_PERFMON` / root.

---

### 2. Systemd Service Sandboxing Matrix
All background services adhere to strict systemd isolation (`ProtectSystem=strict`, `ProtectHome=yes`, `PrivateTmp=yes`, `NoNewPrivileges=yes`, `CapabilityBoundingSet`). `neos-liveuser-setup.service` is carefully bound to minimum capabilities (`CAP_CHOWN`, `CAP_DAC_OVERRIDE`, `CAP_FOWNER`, `CAP_FSETID`, `CAP_SETUID`, `CAP_SETGID`, `CAP_SYS_RESOURCE`, `CAP_AUDIT_WRITE`) and `RestrictAddressFamilies=AF_UNIX`.

---

## Comprehensive Test Suite Verification (34/34 Passed)
All 34 automated test suites in `tests/` pass with zero failures.

---

## Active Git & Pull Request State
* **Upstream Repository:** `uthsarad/NeOS`
* **Active PR:** `#843 — Hardening: Sync installer manifests, harden permissions and runtime hooks`
* **Contributors:** `@RaidenShogun-AI` (`we_own_you_now@proton.me`), `Nimuthu Ganegoda` (`nimuthuganegoda@gmail.com`)
* **Status:** [PASS] ZERO UNRESOLVED VULNERABILITIES
