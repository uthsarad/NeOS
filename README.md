# NeOS (Next Evolution Operating System)

[![Build NeOS ISO](https://github.com/uthsarad/NeOS/actions/workflows/build-iso.yml/badge.svg?branch=main)](https://github.com/uthsarad/NeOS/actions/workflows/build-iso.yml)
![Status](https://img.shields.io/badge/Status-Active_Development-0078D4?style=flat-square)
![Architecture](https://img.shields.io/badge/Arch-x86__64-informational?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)

**NeOS** is a curated, snapshot-based Arch Linux desktop distribution engineered for predictable behavior, system stability, and a refined **KDE Plasma 6** experience. Designed for users transitioning from Windows, NeOS bridges the gap between the flexibility of a rolling release and the reliability of a validated workstation environment.

---

## 🚀 Core Objectives

*   **Snapshot-Gated Stability**: Coherent package sets are validated and promoted via Btrfs snapshots to minimize breakage.
*   **Refined User Experience**: A polished KDE Plasma 6 environment pre-configured with Windows-familiar defaults and workflows.
*   **Automated Hardware Optimization**: Integrated driver management for NVIDIA, AMD, and Intel hardware, including virtualization support.
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
| 👨‍💻 **[Nimuthu Dahanaike](https://github.com/NimuthuGanegoda)** | Project Architect and Lead Maintainer. |

---

## 📚 Technical Documentation

Comprehensive documentation is available in the `docs/` directory:

*   **[Deployment Handbook](docs/HANDBOOK.md)** - Installation and initial setup.
*   **[System Architecture](docs/ARCHITECTURE.md)** - In-depth look at the NeOS stability model.
*   **[Development Roadmap](docs/ROADMAP.md)** - Feature milestones and release phases.
*   **[Hardware Support](docs/VM_STARTUP.md)** - Driver management and virtualization notes.
*   **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Recovery and common issue resolution.

---

## 🛠️ Local Build Instructions

To generate a NeOS ISO locally, ensure `archiso` is installed and execute the build script from the repository root:

```bash
sudo ./build.sh
```

The build process is fully automated via GitHub Actions, with verified ISOs available in the **[Releases](https://github.com/uthsarad/NeOS/releases)** section.

---

## 🤝 Contributing

We welcome technical contributions that align with our stability-first philosophy. Please consult the **[Contribution Guidelines](CONTRIBUTING.md)** before submitting pull requests.

---

**Developed by Nimuthu Ganegoda | Project NeOS | 2026**
