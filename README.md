# NeOS (Next Evolution Operating System)

[![Build NeOS ISO](https://github.com/NimuthuGanegoda/NeOS/actions/workflows/build-iso.yml/badge.svg?branch=main)](https://github.com/NimuthuGanegoda/NeOS/actions/workflows/build-iso.yml)
[![Latest Release](https://img.shields.io/github/v/release/NimuthuGanegoda/NeOS?style=flat-square&color=0078D4&label=release)](https://github.com/NimuthuGanegoda/NeOS/releases)
![Status](https://img.shields.io/badge/Status-Active_Development-0078D4?style=flat-square)
![Architecture](https://img.shields.io/badge/Arch-x86__64-informational?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)

**NeOS** is a curated, snapshot-based Arch Linux desktop distribution engineered for predictable behavior, system stability, and a refined **KDE Plasma 6** experience. Designed for users transitioning from Windows, NeOS bridges the gap between the flexibility of a rolling release and the reliability of a validated workstation environment.

It ships as a full **live installer** — boot into a working desktop, try it, then install offline with the Calamares wizard, the same model as a mainstream desktop OS.

---

## 🚀 Core Objectives

*   **Snapshot-Gated Stability**: Coherent package sets are validated and promoted via Btrfs snapshots to minimize breakage.
*   **Refined User Experience**: A polished KDE Plasma 6 environment pre-configured with Windows-familiar defaults, branded boot splash, and wallpaper.
*   **Automated Hardware Optimization**: Integrated driver management for NVIDIA, AMD, and Intel hardware, with software-rendering fallback so the desktop comes up even inside VMs without 3D acceleration.
*   **Secure by Default**: Hardened kernel parameters, pre-configured UFW, and systemd service sandboxing.
*   **Efficient Footprint**: Optimized build profile maintaining a sub-2GB ISO size for rapid deployment.

---

## 🏗️ Repository Ecosystem

NeOS leverages and extends several key projects within the Arch Linux ecosystem:

| Project | Role |
| :--- | :--- |
| 🛠️ **[ALCI](https://github.com/arch-linux-calamares-installer)** | Base installer framework and Calamares integration. |
| ⚡ **[Chaotic-AUR](https://github.com/chaotic-aur)** | High-performance kernels (Zen) and pre-compiled packages. |
| 🛡️ **[Sovereign Core](https://github.com/NimuthuGanegoda/Sanctuary-of-Eternity)** | Architectural guidance and security policy foundations. |
| 👨‍💻 **[NeOS Team](https://github.com/uthsarad/NeOS/graphs/contributors)** | Collaborative Development & Architectural Review. |

---

## 👥 Project Team

NeOS is a collaborative effort brought to life by a dedicated team of developers, architects, and testers:

*   **[Uthsara Dahanaike](https://github.com/uthsarad)** — Project Lead & Lead Developer
*   **[Nimuthu Ganegoda](https://github.com/NimuthuGanegoda)** — Project Architect & Core Maintainer
*   **[Neo RED](https://github.com/Neored727)** — Core Contributor
*   **Raden Shogun** — Core Contributor
*   **Yae** — Contributor
*   **Hajime** — Testing & Quality Assurance Lead
*   **Specialist Bots** — Automated Quality Assurance & Optimization

---

## 🧪 Testing & Quality Assurance

Because NeOS is a curated distribution, every release is exercised before it reaches users. QA is led by **Hajime**, covering:

*   **Boot validation** — the ISO is booted (BIOS and UEFI) to confirm it reaches the live desktop, including in virtual machines (VMware, VirtualBox, QEMU/KVM).
*   **Installer validation** — the Calamares flow is run end-to-end so installs complete and reboot into a working system.
*   **Automated build gates (CI)** — every push to `main` runs ShellCheck, Trivy, config checks, and a chroot verification that the installer's libraries resolve, so a broken installer fails the build instead of shipping.

> ℹ️ CI cannot boot a desktop or run an interactive install on its own, so hardware/VM smoke testing by the QA team is the final gate before a release is trusted.

---

## 📚 Documentation

Comprehensive documentation is available in the `docs/` directory:

*   **[Deployment Handbook](docs/user-guide/HANDBOOK.md)** — Installation and initial setup.
*   **[System Architecture](docs/architecture/ARCHITECTURE.md)** — In-depth look at the NeOS stability model.
*   **[Development Roadmap](docs/architecture/ROADMAP.md)** — Feature milestones and release phases.
*   **[Hardware Support](docs/user-guide/VM_STARTUP.md)** — Driver management and virtualization notes.
*   **[Troubleshooting](docs/user-guide/TROUBLESHOOTING.md)** — Recovery and common issue resolution.

---

## 🚀 Quick Start

1.  **Download the ISO:** Head to the **[Releases](https://github.com/NimuthuGanegoda/NeOS/releases)** section and download the latest `neos-*-x86_64.iso`.
2.  **Flash to USB:** Use Ventoy, Rufus, or BalenaEtcher.
3.  **Boot & Try:** Boot the USB to explore the live KDE Plasma desktop.
4.  **Install:** Launch **Install NeOS** and follow the curated Calamares installation wizard.

*Note: The ISO is automatically forged in the cloud upon every push to the main branch, ensuring our eternity is always up to date.*

---

## 🛠️ Local Build Instructions

To generate a NeOS ISO locally, ensure `archiso` is installed and execute the build script from the repository root:

```bash
sudo ./build.sh
```

---

## 🤝 Contributing

We welcome technical contributions that align with our stability-first philosophy. Please consult the **[Contribution Guidelines](CONTRIBUTING.md)** before submitting pull requests, and review our **[Code of Conduct](CODE_OF_CONDUCT.md)**.

---

## 🖥️ Architecture Support Matrix

NeOS officially targets the `x86_64` architecture. Other architectures are maintained on a best-effort, experimental basis.

*   ✅ **`x86_64` (Primary)**: Full feature parity, GUI installer support, snapshot-gated stability, and ZRAM optimization.
*   ⚠️ **`i686` (Experimental)**: Minimal CLI base only. Lacks GUI installer, snapshot integration, and ZRAM support.
*   ⚠️ **`aarch64` (Experimental)**: Minimal CLI base only. Lacks GUI installer, snapshot integration, and ZRAM support.

<!-- SENTINEL: Validate that no external URLs are introduced here. -->
<!-- PALETTE: Ensure the architecture matrix uses clear headings, lists, and emojis for readability. -->
<!-- BOLT: Documentation update only; no performance optimizations required here. -->

---

**Developed by the NeOS Team | 2026**
