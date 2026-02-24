#!/bin/bash
# NeOS Automatic Update Script
# Creates snapshot before updates and handles rollback capability

set -euo pipefail

# Sentinel: Enforce root execution
if [ "$EUID" -ne 0 ]; then
   echo "This script must be run as root"
   exit 1
fi

LOG_FILE="/var/log/neos-autoupdate.log"
LOCK_FILE="/run/neos-autoupdate.lock"

# Sentinel: Set strict umask globally
# This ensures all files created by this script (including lock file and logs)
# default to 0600 permissions, preventing race conditions during creation.
umask 0077

# Sentinel: Secure Directory Check
# Validates that the directory is owned by root and not writable by others (unless sticky).
# This mitigates TOCTOU attacks where an attacker replaces a file with a symlink in an insecure directory.
check_secure_dir() {
    local file_path="$1"
    local dir_path
    dir_path=$(dirname "$file_path")

    # Check if directory exists
    if [ ! -d "$dir_path" ]; then
        echo "ERROR: Directory $dir_path does not exist." >&2
        return 1
    fi

    # Check ownership and permissions using stat
    # %u: Owner UID (should be 0)
    # %a: Octal permissions
    local stats
    stats=$(stat -c "%u %a" "$dir_path")
    local owner=${stats%% *}
    local perms=${stats#* }

    # Owner must be root (0)
    if [ "$owner" -ne 0 ]; then
        echo "ERROR: Directory $dir_path is not owned by root (UID $owner)." >&2
        return 1
    fi

    # Check for world-writability and sticky bit
    # If 4 digits (e.g., 1777), first digit is special bits.
    # If 3 digits (e.g., 755), no special bits.

    local sticky=0
    local world_writable=0

    if [ ${#perms} -eq 4 ]; then
        # Check first digit for sticky bit (1)
        if [ $(( ${perms:0:1} & 1 )) -eq 1 ]; then
            sticky=1
        fi
        # Use last 3 digits for permission check
        perms=${perms:1}
    fi

    # Check last digit (other permissions)
    local other_perm=${perms: -1}
    if [ $(( other_perm & 2 )) -eq 2 ]; then
        world_writable=1
    fi

    if [ "$world_writable" -eq 1 ] && [ "$sticky" -eq 0 ]; then
        echo "ERROR: Directory $dir_path is world-writable and not sticky. Unsafe." >&2
        return 1
    fi

    return 0
}

# Verify directories and secure existing files
for FILE in "$LOG_FILE" "$LOCK_FILE"; do
    if ! check_secure_dir "$FILE"; then
        echo "Security check failed for $FILE directory. Aborting." >&2
        exit 1
    fi
    # If file exists, ensure strict permissions (safe because we verified directory)
    if [ -e "$FILE" ]; then
        chmod 600 "$FILE"
    fi
done

# Log function
log() {
    echo "$(/usr/bin/date '+%Y-%m-%d %H:%M:%S') - $1" | /usr/bin/tee -a "$LOG_FILE"
}

# Sentinel: Prevent race conditions and DoS using flock
# Use append mode (>>) to prevent truncation of the target file if it exists.
# Combined with umask 0077 and secure directory check, this is safe.
exec 9>> "$LOCK_FILE"
if ! /usr/bin/flock -n 9; then
    log "Update already running (lock held), exiting."
    exit 1
fi

# Restore standard umask for external tools (pacman/snapper)
# This prevents creating system files with overly restrictive permissions
umask 0022

# Sentinel: Dependency Check - Ensure snapper is installed
if ! command -v /usr/bin/snapper &>/dev/null; then
    log "ERROR: snapper not found. Cannot perform snapshot-based updates."
    exit 1
fi

# Sentinel: Configuration Check - Ensure root is Btrfs
if ! /usr/bin/findmnt -n -o FSTYPE / | /usr/bin/grep -q "btrfs"; then
    log "ERROR: Root filesystem is not Btrfs. Cannot perform snapshot-based updates."
    exit 1
fi

# Create pre-update snapshot
log "Creating pre-update snapshot..."
PRE_SNAP_ID=$(/usr/bin/snapper --config=root create --type pre --cleanup-algorithm timeline --print-number --description "Pre-automatic-update-$(/usr/bin/date +%Y%m%d_%H%M%S)")
log "Pre-update snapshot created: $PRE_SNAP_ID"

# Run system update
log "Starting system update..."
if /usr/bin/pacman -Syu --noconfirm; then
    log "System update completed successfully"
    
    # Create post-update snapshot
    POST_SNAP_ID=$(/usr/bin/snapper --config=root create --type post --cleanup-algorithm timeline --pre-number "$PRE_SNAP_ID" --print-number --description "Post-automatic-update-$(/usr/bin/date +%Y%m%d_%H%M%S)")
    log "Post-update snapshot created: $POST_SNAP_ID"
    
    # Optionally clean old snapshots (keep last 10)
    log "Cleaning old snapshots..."
    /usr/bin/snapper --config=root cleanup number
    
    log "Automatic update process completed successfully"
else
    log "System update failed, attempting rollback to snapshot $PRE_SNAP_ID"
    
    # Attempt rollback to pre-update snapshot
    if /usr/bin/snapper rollback "$PRE_SNAP_ID"; then
        log "Rollback to snapshot $PRE_SNAP_ID successful, system requires reboot"
        # Schedule reboot after delay to allow for notification
        /usr/bin/shutdown -r +1 "NeOS automatic update failed, rolled back to previous state. Rebooting in 1 minute."
    else
        log "Rollback failed, manual intervention required"
        exit 1
    fi
    
    exit 1
fi
