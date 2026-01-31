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

## Repository focus
This repository contains the architectural guidance, roadmap, and configuration scaffolding for the NeOS distribution. It is written for contributors, reviewers, and early users as NeOS approaches its first public beta.

## Documentation
- [Architecture Overview](docs/ARCHITECTURE.md)
- [Development Roadmap](docs/ROADMAP.md)
- [Performance Standards](docs/PERFORMANCE.md)
- [VM Startup Modules](docs/VM_STARTUP.md)
- [Bootloader and Initramfs Defaults](docs/BOOTLOADER.md)

## Contributing
NeOS is a distribution with clear opinions. Contributions should align with the stability-first, Windows-familiar desktop goals described in the architecture and roadmap documents.

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
