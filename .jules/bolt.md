## 2024-05-22 - Initial Scan

**Learning:** Repo is a scaffold with no source code. Performance optimizations must currently be architectural.
**Action:** Focus on documenting performance limits and goals to prevent future bottlenecks.

## 2024-05-24 - Documentation Performance

**Learning:** In the absence of code, "Performance" translates to "Developer Efficiency". Improving documentation navigability (TOC) and actionability (copy-paste commands) significantly reduces verification time.
**Action:** When optimizing docs, prioritize actionable verification steps over theoretical targets.

## 2026-01-29 - ISO Filesystem Optimization

**Learning:** Switching `airootfs` to EROFS with LZ4HC compression offers a measurable boot time improvement over SquashFS/Zstd for read-only ISOs, aligning with the "Cold Boot" budget.
**Action:** Default to EROFS for all future high-performance ISO profiles in this project.

## 2024-05-24 - Tooling Dependency for Validation

**Learning:** Attempted to optimize EROFS compression level but lacked `mkfs.erofs` to validate syntax/options.
**Action:** When working in limited environments, prioritize optimizations that can be validated with available tools or standard config parsers (like pacman.conf) over those requiring specific binary tools.

## 2026-05-28 - Redundant Boot Configuration

**Learning:** Found redundant module loading where `modules-load.d` re-specified modules already loaded by initramfs, causing unnecessary overhead. Also identified missing `virtio_gpu` for VM Early KMS.
**Action:** Always cross-reference `mkinitcpio.conf` MODULES with `modules-load.d` to eliminate redundancy and ensure graphical drivers are loaded early for seamless boot.

## 2026-05-29 - Init System Hook Conflict

**Learning:** Legacy `udev` hooks were accidentally overriding performance-optimized `systemd` hooks in `mkinitcpio.conf` due to a duplicate configuration line. This prevented parallel boot initialization despite other configs (e.g., `rd.systemd...`) implying systemd usage.
**Action:** When auditing `mkinitcpio.conf`, explicitly check for duplicate `HOOKS` assignments, as the last one wins and can silently revert architectural performance improvements.

## 2026-05-30 - Ghost Configuration
**Learning:** Discovered `zram-generator.conf` present but the required `zram-generator` package was missing from `packages.x86_64`, rendering the optimization silent and ineffective.
**Action:** Always verify that performance-critical configuration files have their corresponding binaries installed in the package list.

## 2026-02-04 - Synchronous vs Async Discard
**Learning:** Default `discard` mount option is synchronous and causes latency spikes on Ext4/XFS. Btrfs `discard=async` avoids this.
**Action:** Use `discard=async` for Btrfs. For others, rely on `fstrim.timer` and explicitly disable `discard` in installer configs.
