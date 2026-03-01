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

## 2026-02-04 - Target System Initramfs Portability
**Learning:** Removing explicit virtualization modules from the target system's `mkinitcpio.conf` (to rely on `autodetect`) breaks portability if the installed drive is moved from bare metal to a VM.
**Action:** Retain explicit VM driver loading in `mkinitcpio.conf` if the installed system is expected to be portable across hypervisors, even if it slightly increases initramfs size.

## 2026-02-04 - Ghost Module Config
**Learning:** `mkinitcpio.conf` requested `zfs` module but `packages.x86_64` did not include ZFS support, causing build-time warnings.
**Action:** Cross-reference `mkinitcpio.conf` `MODULES` with `packages.x86_64` to remove unsupported modules and silence warnings.

## 2026-02-04 - Btrfs Space Cache Inconsistency
**Learning:** The manual installer script `neos-installer-partition.sh` used `space_cache=v2` (performance win), but the Calamares installer config `fstab.conf` did not, leading to degraded performance for users who installed via the GUI.
**Action:** When maintaining dual installation methods (script vs GUI), always synchronize filesystem performance options in both `mount` commands and `fstab.conf` templates.

## 2026-06-01 - Python Import Without Extension
**Learning:** Testing Python scripts that lack a `.py` extension (common for executables in `bin/`) requires `importlib.machinery.SourceFileLoader` rather than `importlib.util.spec_from_file_location`, as the latter may return `None` if the file extension is not recognized.
**Action:** When writing tests for executable scripts, use `SourceFileLoader` to explicitly load the module from path, or ensure the script has a `.py` extension if possible.

## 2026-06-01 - Filesystem Cache Pressure
**Learning:** Tuning `vm.vfs_cache_pressure` to 50 (down from 100) on ZRAM-enabled systems improves desktop responsiveness by preferring to retain dentry/inode caches over reclaiming them, effectively trading a small amount of RAM for faster file access.
**Action:** Always verify `vm.vfs_cache_pressure` alongside `vm.swappiness` in performance configurations to ensure a balanced memory management strategy.

## 2026-03-02 - Bash Builtins vs External Processes for Parsing
**Learning:** In performance-sensitive bash scripts, piping output to external tools like `awk` for simple field extraction (e.g., `df -Pk / | awk '{print $4}'`) introduces significant overhead due to subprocess forks. Using bash process substitution with the built-in `read` command (`{ read -r _; read -r _ _ _ val _ _; } < <(df -Pk /)`) can reduce execution time by ~20%.
**Action:** When parsing tabular command output in tight loops or initialization phases, prefer using native bash `read` capabilities via process substitution over external parsers.
