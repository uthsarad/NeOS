# NeOS Development Roadmap

## Scope and Philosophy
NeOS is a curated, snapshot-based Arch Linux desktop distribution. The roadmap reflects the responsibility of a full distribution: stability, update coordination, and a Windows-familiar KDE Plasma experience. The primary audience is Windows switchers and general desktop users, not Arch power users.

## Phase 0: Foundations and Policy
**Goals**
- Establish distribution identity, policies, and contributor expectations.
- Define the snapshot-based release model and update promotion gates.

**Key Deliverables**
- Packaging and repository policy (what is mirrored vs curated, snapshot cadence).
- Security and update policy (rollback expectations, staged promotion rules).
- Baseline Plasma defaults (Wayland-first, Windows-like UX conventions).

## Phase 1: Repository Snapshot Infrastructure
**Goals**
- Build the infrastructure that makes snapshot-based rolling releases reliable.

**Workstreams**
1. **Snapshot pipeline**
   - Snapshot upstream Arch repositories.
   - Promote snapshots through *staging → stable* only after validation.
2. **QA and validation**
   - Automated smoke tests for KDE/Qt and driver changes.
   - Manual QA for desktop-critical updates and kernel bumps.
3. **Rollback readiness**
   - Retain prior packages for quick downgrade.
   - Define Btrfs snapshot rollback guidance for end users.

**Acceptance Criteria**
- A documented and repeatable snapshot promotion process.
- Staging snapshots validated before stable release.

## Phase 2: ISO Build and Branding
**Goals**
- Produce reproducible installation media with NeOS defaults and branding.

**Workstreams**
1. **archiso profile**
   - Maintain a NeOS profile with correct metadata and repository configuration.
   - Support both UEFI and BIOS boot paths.
2. **Branding and defaults**
   - `neos-artwork` and `neos-settings` integrated in the ISO.
   - KDE Plasma 6 defaults aligned with Windows-like UX.
3. **Storage defaults**
   - Btrfs by default with snapshot-ready subvolumes.
   - GRUB as the standard bootloader for dual-boot reliability.

**Acceptance Criteria**
- ISO builds are reproducible across CI environments.
- Clean install reaches a ready-to-use desktop without manual fixes.

## Phase 3: Installer and First-Boot UX
**Goals**
- Deliver a Windows-like installation flow and a reliable first-boot experience.

**Workstreams**
1. **Calamares customization**
   - Replace Windows / Dual Boot flows.
   - Sensible defaults with an optional advanced mode.
2. **First-boot setup**
   - Post-install updates and driver verification.
   - Firmware installation and opt-in diagnostics.

**Acceptance Criteria**
- New users reach a functioning desktop with no terminal steps.
- Dual-boot setup works reliably on common hardware.

## Phase 4: Hardware & Driver Reliability
**Goals**
- Ensure hardware works out of the box, with NVIDIA treated as a first-class requirement.

**Workstreams**
1. **Nvidia enablement**
   - Automatic detection and proprietary driver installation.
   - `nvidia-dkms` availability enforced on first boot.
2. **Firmware coverage**
   - Curated Wi-Fi and laptop firmware packages.
3. **Laptop defaults**
   - Power profiles and known-quirk presets for common OEM devices.

**Acceptance Criteria**
- Nvidia users boot to working graphics without manual intervention.
- Common laptops function without driver troubleshooting.

## Phase 5: Application & Update UX
**Goals**
- Make software management GUI-first and predictable.

**Workstreams**
1. **Discover integration**
   - KDE Discover branded for NeOS and set as default.
   - PackageKit/libalpm for system updates.
2. **Flatpak enablement**
   - Flatpak + Flathub enabled by default for GUI apps.
3. **AUR stance**
   - Document AUR as unsupported by default; opt-in only.

**Acceptance Criteria**
- Users can install and update apps without terminal usage.
- Update UX surfaces clear notes for desktop-critical changes.

## Phase 6: UX Polish and Windows Familiarity
**Goals**
- Deliver a KDE Plasma experience that feels familiar to Windows users.

**Workstreams**
1. **Layout and workflow**
   - Taskbar and launcher positioning aligned with Windows expectations.
   - File manager defaults tuned for familiarity.
2. **Visual consistency**
   - Cohesive theming across KDE and bundled apps.
3. **Welcome experience**
   - Clear onboarding, update prompts, and feature discovery.

**Acceptance Criteria**
- Users can navigate without relearning desktop conventions.
- Visual consistency across core desktop surfaces.

## Phase 7: Public Beta Readiness
**Goals**
- Operate NeOS like a real distribution with predictable maintenance.

**Workstreams**
1. **Release operations**
   - Stable/testing channels with documented promotion rules.
   - CI for ISO builds and snapshot promotion.
2. **Support and feedback**
   - Issue tracking and community support channels.
   - Optional, telemetry-free crash reporting with explicit opt-in.

**Acceptance Criteria**
- Reliable cadence for snapshot releases.
- Clear governance and contributor workflows.

## Risks and Pitfalls
- **Snapshot overhead:** snapshot testing requires sustained CI/QA resources.
- **Driver regressions:** Nvidia and firmware updates can destabilize releases.
- **User expectations:** rolling release must still feel predictable to Windows switchers.

## Success Metrics
- **Install success rate:** high completion rate in test cohorts.
- **Update reliability:** minimal rollback usage after updates.
- **Support volume:** low volume of driver and installation issues.
- **User satisfaction:** positive feedback on usability and polish.
