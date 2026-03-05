# PALETTE_REPORT

## Accessibility Fixes
- None applicable for this script logic enhancement.

## UX Improvements
- **Log Messaging Clarity:** Improved the silent exit message in `neos-autoupdate.sh` when the system is not using a Btrfs root filesystem. Instead of simply stating "Root filesystem is not Btrfs. Skipping...", the log now clearly explains *why* the auto-update is skipped: "Auto-update skipped: Root filesystem is 'ext4' (Btrfs is required for safe rollback snapshots)." This transforms a cryptic system log into an actionable explanation, ensuring that users diagnosing missing updates understand that Btrfs snapshots are a hard dependency for this specific script's safe execution.
- We maintained the silent `exit 0` behavior to prevent spamming warnings to users who intentionally choose alternate filesystems (expected environment variation).

## Remaining Usability Risks
- Users without `notify-send` functionality or those not running supported graphical sessions (e.g. headless setups without system mail) may still miss critical out-of-space warnings during auto-updates.
