# Bolt Report - Performance Optimization

## Optimization Details
- **Target File:** `profile/airootfs/usr/local/bin/neos-installer-partition.sh`
- **Optimization:** Added the `-K` (`--nodiscard`) flag to the `mkfs.btrfs` formatting command.

## Before/After Reasoning
- **Before:** `mkfs.btrfs` performed a synchronous block discard across the entire partition before writing filesystem metadata. On large SSDs or slower NVMe drives, this process could take several seconds to minutes, blocking the installation process.
- **After:** The `-K` flag forces `mkfs.btrfs` to skip the synchronous block discard, creating the filesystem instantly.
- **Why this is safe:** The standard system behavior involves mounting Btrfs with `discard=async` (or using `fstrim.timer`). Any previously used blocks that need to be discarded will be efficiently handled asynchronously in the background by the kernel or systemd timer after the filesystem is mounted, completely unblocking the installer's critical path.

## Remaining Performance Risks
- If the system does not configure `discard=async` in `/etc/fstab` or enable `fstrim.timer`, there might be a slight long-term impact on SSD write amplification. However, both of these are standard features in modern Arch Linux / NeOS installations.
