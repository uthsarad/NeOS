# NeOS

NeOS (Next Evolution Operating System) is a curated, snapshot-based Arch Linux desktop distribution focused on predictable behavior, low breakage, and a Windows-familiar KDE Plasma experience. It is not a thin Arch wrapper or a DIY remix. NeOS owns the stability model, update coordination, and end-user experience.

## What NeOS is
- **A curated Arch-based desktop distribution** with explicit decisions around updates, drivers, and defaults.
- **Snapshot-based rolling release**, where repository snapshots are tested and promoted as coherent sets.
- **KDE Plasma 6–first**, with a polished, KDE Neon–like UX delivered on an Arch base.
- **Windows switcher–friendly**, prioritizing familiar workflows and low-friction onboarding.

## What NeOS is not
- **Not a thin Arch wrapper** that simply points to upstream mirrors.
- **Not a DIY power-user distro** that expects terminal-first management for day-to-day use.
- **Not a frozen release**, but a curated rolling model with snapshot gating and rollback expectations.

## Repository Focus & Structure
This repository serves as the **official Archiso profile** for building the NeOS distribution ISO. It contains the architectural guidance, roadmap, and configuration scaffolding necessary to produce a bootable system. It is written for contributors, reviewers, and early users as NeOS approaches its first public beta.

## Supported Architectures

| Architecture | Tier | Status |
| :--- | :--- | :--- |
| **x86_64** | **Primary** | Officially supported. CI verified. Release blocker. |
| **i686** | **Community** | Experimental. Best-effort support. No guarantees. |
| **aarch64** | **Community** | Experimental. Best-effort support. No guarantees. |

## Documentation
- **[NeOS Mission & Identity](docs/MISSION.md)** - Core philosophy and target audience.
- **[NeOS Brand Structure](docs/BRAND_STRUCTURE.md)** - Brand ethos, voice, and evolution model.
- **[NeOS Handbook (Getting Started)](docs/HANDBOOK.md)** - Start here!
- [Architecture Overview](docs/ARCHITECTURE.md)
- [Development Roadmap](docs/ROADMAP.md)
- [Performance Standards](docs/PERFORMANCE.md)
- [VM Startup Modules](docs/VM_STARTUP.md)
- [Deep Audit Report](docs/DEEP_AUDIT.md) - Comprehensive repository analysis
- [Audit Action Plan](docs/AUDIT_ACTION_PLAN.md) - Prioritized improvement roadmap

## Building NeOS

**⚠️ Important:** If you're experiencing issues with VMs not recognizing the ISO, see [ISO Build Fix Guide](docs/ISO_BUILD_FIX.md).

To build the ISO locally, you can use the provided `build.sh` script, which handles dependency checks and configuration setup:

```bash
sudo ./build.sh
```

For more detailed instructions, refer to the [NeOS Handbook](docs/HANDBOOK.md).

Before building, you can run the Rust-based profile validator to catch duplicate or malformed package manifests:

```bash
bash tests/verify_rust_profile_audit.sh
```


## Rust Integration Direction (3-5% target)

NeOS now includes a Rust-based profile validator under `tools/neos-profile-audit`. A practical next step is to keep Rust usage in the tooling layer while preserving shell compatibility in build scripts:

- Keep policy and manifest validation in Rust CLIs (fast, typed parsing, clearer errors).
- Use shell wrappers in `tests/` to call Rust tools so CI and contributor workflows stay simple.
- Gradually replace brittle text parsing checks in bash/python with focused Rust subcommands.

This keeps Rust around the 3-5% footprint while strengthening reliability in the parts of the project most prone to configuration drift.

## Contributing
NeOS is a distribution with clear opinions. Contributions should align with the stability-first, Windows-familiar desktop goals described in the architecture and roadmap documents.

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
