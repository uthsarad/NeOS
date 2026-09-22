# NeOS Documentation Index

[← Back to the project README](../README.md)

## Documentation

| Document | What it covers |
| :--- | :--- |
| [Deployment Handbook](user-guide/HANDBOOK.md) | Installation, first steps, project structure, building from source. |
| [Troubleshooting (user guide)](user-guide/TROUBLESHOOTING.md) | Recovery, display/scaling issues, snapshot rollback, driver problems. |
| [Virtual machine setup](user-guide/VM_STARTUP.md) | Running NeOS under VMware, VirtualBox and QEMU/KVM. |
| [Secure Boot](SECURE_BOOT.md) | The user-initiated `sbctl` own-keys flow and its trade-offs. |
| [System Architecture](architecture/ARCHITECTURE.md) | The snapshot-gated stability model and how the pieces fit together. |
| [Boot process](architecture/BOOTING.md) | What happens from firmware to desktop. |
| [Bootloader](architecture/BOOTLOADER.md) | GRUB (UEFI) and Syslinux (BIOS) configuration. |
| [Bootstrap](architecture/BOOTSTRAP.md) | Where bootloader/bootstrap code comes from and what this repo owns. |
| [Performance](architecture/PERFORMANCE.md) | Performance budgets and the optimizations behind them. |
| [Roadmap](architecture/ROADMAP.md) | Development phases and milestones. |
| [Mission and identity](architecture/MISSION.md) | Who NeOS is for and what it deliberately is not. |
| [Brand structure](architecture/BRAND_STRUCTURE.md) | Logo, wallpaper, Plymouth/SDDM assets and how they are generated. |

## Architecture decisions (ADRs)

| ADR | Decision |
| :--- | :--- |
| [0001](decisions/0001-linux-lts.md) | Ship `linux-lts` as the default kernel. |
| [0002](decisions/0002-btrfs-snapper.md) | Btrfs + Snapper snapshot strategy. |
| [0003](decisions/0003-calamares.md) | Calamares as the installer. |
| [0004](decisions/0004-plasma-meta.md) | `plasma-meta` for the desktop. |
| [0005](decisions/0005-parallel-downloads.md) | Parallel package downloads. |
| [0006](decisions/0006-ubuntu-parity-capabilities.md) | Two-tier package placement for Ubuntu parity. |
| [0001 (core)](architecture/decisions/0001-core-architecture-decisions.md) | Early core architecture decisions. |

> The ADRs live in two directories: `docs/decisions/` (numbered project decisions)
> and `docs/architecture/decisions/` (the original core decisions). Consolidating
> them is tracked in [reports/v2026.09.22/UPDATES_NEEDED.md](../reports/v2026.09.22/UPDATES_NEEDED.md).

## Audit history and reports

Reports are versioned per release under `reports/`:

| Report | Notes |
| :--- | :--- |
| [2026.09.22 — What needs updating](../reports/v2026.09.22/UPDATES_NEEDED.md) | Current audit: release paperwork, URL drift, CI gates, open engineering items. |
| [2026.09.18 — Deep audit](../reports/v2026.09.18/AUDIT_AND_RECOMMENDATIONS.md) | Whole-repository audit (partly superseded — see the banner in the file). |
| [2026.09.11 — Agent reports](../reports/v2026.09.11/) | Architect, Sentinel, Bolt, Palette, risk and strategic-directive snapshots. |

Archived, superseded material lives in [archive/](archive/) and is kept for
historical context only — do not treat it as current behaviour.
