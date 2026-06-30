# 6. Ubuntu parity capabilities and package placement strategy

Date: 2026-06-29
Status: Accepted

## Context

NeOS is an Arch-based live installer competing with mainstream distributions like Ubuntu 26.04 Desktop. Users migrating from Ubuntu expect feature parity in areas such as firmware updates, accessibility, app distribution, hardware support (NVIDIA, thermal management, WWAN), and Secure Boot. However, NeOS is constrained by a hard 2 GiB ISO size limit for GitHub releases and builds within resource-limited CI environments.

We needed to close the Ubuntu parity gap without exceeding the ISO size budget.

## Decision

We will adopt Ubuntu-equivalent capabilities using Arch packages, applying a **two-tier package placement strategy**:

1. **Live squashfs** (`profile/packages.x86_64`): Only the minimal accessibility speech stack (orca, speech-dispatcher, espeak-ng, espeakup, brltty) is shipped, ensuring the live session supports screen readers. No other new packages go on the live image.

2. **Installed system** (`neos-packages.txt`): All other capabilities are network-pacstrapped at installation time:
   - Firmware: `fwupd`
   - App store: `flatpak` (backend for Discover)
   - Fonts: `noto-fonts-cjk` (CJK language support)
   - NVIDIA: `nvidia-dkms` (kernel module compilation support)
   - Secure Boot: `sbctl`, `mokutil`, `efitools` + `neos-secureboot-setup` helper
   - Hardware/connectivity: `thermald`, `modemmanager`, `networkmanager-openvpn`, `sane`, `sane-airscan`

This two-tier approach allows us to deliver Ubuntu-parity features to the installed system while keeping the live ISO under 2 GiB for reliable GitHub releases and fast CI.

## Consequences

**Benefits:**
- Users get firmware updates, accessibility, app distribution, GPU drivers, thermal management, and wireless/scanner support — achieving feature parity with Ubuntu 26.04.
- The live session is fully functional for accessibility-enabled users (screen reader support).
- Live ISO remains under 2 GiB, unblocking automated GitHub releases and fast CI turnaround.
- Post-install, users have a feature-complete workstation with minimal delay (pacstrap from official/Chaotic repos is fast on good networks).

**Trade-offs:**
- Secure Boot setup is user-initiated post-install (sbctl own-keys model) rather than automatic. This is deliberate: automatic enrollment risks UEFI firmware bugs that brick the machine. Users who want Secure Boot must consciously run `neos-secureboot-setup`, accepting the responsibility.
- NVIDIA drivers require compilation on first boot (dkms + linux-lts-headers present). This adds boot time on first install but ensures compatibility.
- Users on slow or metered networks will experience post-install pacstrap delays; however, the majority of desktop users have adequate bandwidth.
- CJK fonts are not on the live image, so live previews lack CJK rendering. This respects the ISO size constraint; fonts are installed and available immediately on the installed system.

**Acceptance criteria met:**
- Ubuntu parity achieved for firmware, accessibility, app distribution, GPU, thermal, WWAN, and scanner support.
- 2 GiB ISO limit enforced (accessibility live-support requires zero packages beyond the lean speech stack).
- Live accessibility is functional (screen reader works in live session).
- Secure Boot helpers prevent brick risk via user-initiated approach.
