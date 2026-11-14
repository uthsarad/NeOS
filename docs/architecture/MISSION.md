# NeOS Mission and Identity

## Core Mission
NeOS is a curated Arch Linux distribution delivering Windows-level usability with Linux-level power. It bridges the gap between the flexibility of Arch Linux and the reliability expected from a consumer operating system.

## Target Audience
- **Windows Switchers:** Users looking for a familiar desktop paradigm (KDE Plasma) without the learning curve of a "do-it-yourself" Linux installation.
- **Stability Seekers:** Users who want the latest software but require a system that doesn't break on updates.
- **Power Users:** Those who appreciate Arch's underlying architecture but prefer a pre-configured, battle-tested starting point.

## What NeOS is NOT
- **Not a DIY Distro:** NeOS provides sensible defaults, hardware-aware session selection (Plasma Wayland with Xfce X11 fallback), firewall/sysctl hardening, and pre-configured recovery tools out of the box.
- **Not Unprotected Rolling Updates:** Today (`Beta` channel), packages come from upstream Arch Linux, Chaotic-AUR, and Garuda repositories, with every update locally protected by automatic Btrfs pre/post snapshots (`snapper` + `grub-btrfs` + `neos-rollback`). Hosted snapshot-gated repository tiers are planned on the [Roadmap](ROADMAP.md).
