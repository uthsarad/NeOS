# Website alignment — OS vs. neosweb.netlify.app

**Date:** 2026-10-03 · **Branch:** `testing` · **Website source:** `uthsarad/NeOSweb` (default branch)

The site was read page by page (index, install, manual chapters 01–05, FAQ, news) and
each factual claim about the OS was checked against this repository. Visual themes and
site styling were out of scope. Each claim landed in one of three outcomes:

1. **Fixed in the OS:** the website was right and the OS fell short.
2. **Website should change:** the claim describes something NeOS does not do, and
   building it is a product decision (listed with proposed wording).
3. **Verified:** true as written.

## 1. Fixed in the OS (this release)

| Website claim | Problem in the OS | Fix |
| :--- | :--- | :--- |
| Manual ch. 04 / FAQ: *"boot the previous snapshot from the GRUB menu"* | No GRUB snapshot entries existed: `grub-btrfs` was not installed. | `grub-btrfs` + `grub-btrfsd` on installed systems; a **NeOS snapshots** submenu; `grub-btrfs-overlayfs` initramfs hook so a read-only snapshot reaches the desktop. |
| Index: *"Ready to roll back"*; manual: rollback from the desktop | The Operations Hub ran `snapper rollback`, which changes the Btrfs default subvolume. NeOS mounts root by name (`subvol=/@`), so rollback silently did nothing. | New `neos-rollback`: swaps `@` for a writable copy of the snapshot and keeps the old root. Hub uses it. Gate: `tests/verify_rollback.sh`. |
| Manual: dual boot / GRUB menu recovery | Calamares regenerated `/etc/default/grub` (`grubcfg overwrite: true`), dropping os-prober (Windows missing on dual boot), the theme and NeOS kernel parameters. | `grubcfg` edits in place; `GRUB_DISABLE_OS_PROBER=false`; 3 s timeout. |
| Hero terminal: `PRETTY_NAME="NeOS 2026.09 (Marlin Beta)"` | os-release said `NeOS Beta`; no codename anywhere. | `NeOS <YYYY.MM> (Beta)`; CI inserts the build codename and sets `VERSION_CODENAME`, also in the installer branding. |
| Manual ch. 04: Hub reports *"Stable"*, channel handled by *"staged deployments"* | The OS repeated the same claim; there is no staging pipeline. | The Hub now says "Beta channel, updates from the Arch repositories, protected by snapshots". (The website text should follow; see 2.3.) |
| README (linked from the site) | Credited ALCI, NeoCortex, "Sovereign Core", an AI persona; claimed Zen kernels and a named QA lead. | README rewritten around the website's positioning with only verifiable claims. |

## 2. Website should change

Each item gives the current website text, what the OS actually does, and the wording
to use instead. Where the website describes something worth building, that is noted;
none of these are fixed by editing the OS alone.

### 2.1 "Tested, then promoted" package sets (index, features, manual ch. 04)
- **Site:** *"Every package set is grouped, tested together and only then promoted."*
  *"Packages are grouped and tested as coherent sets before promotion."*
- **Reality:** installed systems update straight from the Arch mirrors
  (`/etc/pacman.d/neos-mirrorlist`). There is no NeOS staging/stable repository yet
  (`docs/architecture/ARCHITECTURE.md` now labels it as the target design).
- **Proposed:** *"Every update is wrapped in Btrfs snapshots, before and after, so
  anything that slips through is one reboot from undone. Curated, pre-tested package
  sets are on the roadmap."*

### 2.2 Offline installation (install page, manual ch. 01, news)
- **Site:** *"then install offline with the Calamares wizard"*; *"Fully offline
  installs are supported … without one it installs from the verified packages on the
  medium"*; news item *"Fully offline installation, now supported"*; VM chapter: keep
  the ISO attached *"for the offline package store"*.
- **Reality:** only an ISO built locally with `sudo ./build.sh` embeds the offline
  repository. CI builds with `--no-offline-repo`, so **every published ISO needs a
  network connection to install.**
- **Proposed:** *"Keep the machine online during installation; packages are fetched
  from the Arch mirrors. (A self-built ISO can embed them for offline installs.)"*
- **Or build it:** drop `--no-offline-repo` from `.github/workflows/build-iso.yml`.
  This makes the ISO noticeably larger and the CI build slower, and it has not been
  tried on a GitHub runner — a maintainer decision.

### 2.3 Release channels (manual ch. 04)
- **Site:** *"installed channel reported as Stable in the Operations Hub … handled by
  the project's staged deployments"*.
- **Proposed:** *"There is one channel during the beta. The Operations Hub reports it
  as Beta; channel selection arrives with the first stable release."*

### 2.4 i686 / aarch64 builds (install requirements, manual ch. 01/02, FAQ)
- **Site:** *"i686 / aarch64 builds are experimental, CLI only."*
- **Reality:** no such builds exist; the profile and CI are x86_64 only.
- **Proposed:** *"x86_64 (64-bit) only."* Remove the Apple-silicon aside about an
  "experimental aarch64 build".

### 2.5 CI "ISO size gate" (manual ch. 05)
- **Site:** *"CI runs ShellCheck, configuration checks and an ISO size gate … boot …
  testing is still done by hand"*.
- **Reality:** the size gate was removed when releases moved to SourceForge, and CI
  now boots every ISO in QEMU (BIOS and UEFI) and fails unless the desktop renders.
- **Proposed:** *"CI runs ShellCheck, a Trivy scan, ~60 configuration gates and boots
  every ISO in QEMU (BIOS and UEFI), failing unless the live desktop renders.
  Interactive installs are still tested by hand in VMs."*

### 2.6 NVIDIA driver name (FAQ)
- **Site:** *"NeOS ships the tooling and `nvidia-open-dkms`"*.
- **Reality:** installed systems get `nvidia-open-lts` (prebuilt for the LTS kernel,
  no DKMS build).
- **Proposed:** replace `nvidia-open-dkms` with `nvidia-open-lts`.

### 2.7 Wayland vs. X11 (FAQ vs. manual)
- **Site:** the FAQ says *"Wayland, by default"*; the manual (ch. 03) correctly says X11
  is the default and Wayland is selectable in SDDM.
- **Reality:** X11 is the default (`DisplayServer=x11`, `Session=plasmax11`) for VM and
  older-GPU compatibility; the Wayland session is installed.
- **Proposed FAQ answer:** *"X11 by default on NeOS, for the widest GPU and VM
  compatibility. Plasma's Wayland session is installed; pick it from the session menu
  on the login screen. Upstream Plasma defaults to Wayland and plans to drop the X11
  session in 6.8, so NeOS will follow."*

### 2.8 `snapper rollback` (FAQ)
- **Site:** *"roll back from the desktop with `snapper rollback`"*.
- **Reality:** `snapper rollback` has no effect on NeOS's layout (see section 1).
- **Proposed:** *"… or roll back from the desktop with NeOS Operations Hub → System
  Snapshot & Rollback (`sudo neos-rollback <number>` in a terminal)."*

### 2.9 Driver manager (manual ch. 03)
- **Site:** *"neos-driver-manager … pulls the matching package sets with DKMS support"*.
- **Reality:** drivers are preinstalled; the tool detects hardware, loads modules and
  reports which driver is in use or which package to install. It does not install
  anything.
- **Proposed:** *"Drivers for NVIDIA, AMD and Intel graphics are preinstalled;
  `neos-driver-manager` reports what is in use and suggests packages for anything
  missing."*

### 2.10 Accessibility tool (manual ch. 03)
- **Site:** *"neos-accessibility applies sensible accessibility defaults and can be
  re-run any time."*
- **Reality:** it starts console speech (espeakup) when the **Screen Reader** boot
  entry is chosen, and does nothing otherwise.
- **Proposed:** *"Choose **NeOS (Screen Reader)** in the boot menu to start with speech
  output enabled."*

### 2.11 Welcome app (manual ch. 03)
- **Site:** *"walks you through appearance, privacy and update choices"*.
- **Reality:** the welcome window offers **Try NeOS** / **Install NeOS** and a short
  feature overview; it has no settings pages.
- **Proposed:** *"A welcome window introduces NeOS and offers to try or install it."*

## 3. Verified as written

Calamares flow (location → keyboard → partition → users → summary); snapper hooks around
every pacman transaction; timeline snapshots; the daily snapshot-protected
`neos-autoupdate.timer`; X11 default (manual); `neos-display-sync` rotation and
`--scale` options; VM software-rendering fallback; ZRAM swap; UFW, hardened sysctl, the
sshd settings and service sandboxing; Secure Boot tooling and "Secure Boot off" to boot;
Copy-to-RAM / Safe Graphics boot entries; BIOS (Syslinux) and UEFI (GRUB) boot paths;
`SHA256SUMS`, `SHA512SUMS`, the torrent and the VirtualBox/VMware templates on each
release; the `neos-<Codename>-Beta-x86_64.iso` file name; system requirements (4 GB RAM,
20 GB disk, 8 GB USB).
