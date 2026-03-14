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

## 2026-03-03 - Stream-Based Parsing for Unbounded List Files
**Learning:** In Rust tooling processing potentially large configuration files (like extensive package lists or massive mirrorlists), using `fs::read_to_string` loads the entire file into memory as a single string before iteration, which is highly inefficient for files scaling to thousands of lines. This is especially true when searching for the *first* occurrence of a string, as `read_to_string` unnecessarily reads and allocates memory for the rest of the file.
**Action:** When parsing list-like files in Rust where size may be unbounded or large, utilize `File::open` paired with `io::BufReader::new().lines()` for memory-efficient, incremental line-by-line streaming, and combine this with an early loop exit (`break`) once the desired condition is met to minimize I/O and processing overhead.

## 2026-03-05 - File System Identification Overhead
**Learning:** Using `findmnt -n -o FSTYPE /` to check the root filesystem type in a bash script incurs measurable overhead because it requires parsing system mount tables (`/proc/self/mountinfo`).
**Action:** In performance-sensitive bash scripts, prefer `stat -f -c %T <path>` over `findmnt` for filesystem type checks. `stat` directly calls the `statfs` syscall, resulting in a ~20-30% faster execution without parsing overhead.

## 2026-06-15 - Bash Builtins vs Subprocesses in CI Logic
**Learning:** In GitHub Action shell scripts (`.github/workflows/build-iso.yml`) and validation scripts (`tests/verify_iso_smoketest.sh`), using `awk` for simple math (like MB conversion) or `find` piped to `wc -l` to count files in a single directory spawns unnecessary subprocesses. These can be optimized entirely using native bash integer arithmetic (`printf -v var "%d.%02d" "$((bytes/1048576))" "$(((bytes%1048576)*100/1048576))"`) and bash array globbing (`shopt -s nullglob; files=(dir/*.iso); count=${#files[@]}`).
**Action:** Default to using native bash globbing and arithmetic expansions for simple file discovery and math formatting within performance-sensitive bash contexts to eliminate external binary execution overhead.

## 2026-06-16 - Subprocess Overhead in CI String Slicing
**Learning:** Common CI patterns like slicing a Git SHA via `$(echo ${{ github.sha }} | cut -c1-7)` launch multiple unnecessary subprocesses (`echo`, `cut`). This incurs measurable shell overhead inside GitHub Actions.
**Action:** Always prefer native bash parameter expansion (e.g., `${GITHUB_SHA:0:7}`) for simple string slicing in CI/CD pipelines to eliminate process forking delays.

## 2026-03-05 - Stream Parsing Buffer Reuse in Rust
**Learning:** While `BufReader::lines()` in Rust offers an ergonomic way to parse files incrementally, it inherently allocates a new `String` for every single line. When parsing extensive list-like files (e.g., package lists or mirrorlists) or frequently skipping commented sections, this per-line allocation introduces measurable memory overhead.
**Action:** For performance-critical file parsing loops in Rust, replace the `.lines()` iterator with a `while reader.read_line(&mut raw_line)` construct using a single, reused `String` buffer (clearing it between iterations). This prevents repeated heap allocations and significantly improves stream parsing performance.

## 2024-05-25 - API-Driven Workflow Optimization

**Learning:** GitHub Actions workflows that solely utilize API-driven tools like the `gh` CLI (e.g., `gh pr merge "$PR_URL"`) do not require local repository context. The `actions/checkout` step in these cases adds unnecessary execution time and consumes runner resources.
**Action:** Always omit the `actions/checkout` step in workflows that only perform remote API operations.
