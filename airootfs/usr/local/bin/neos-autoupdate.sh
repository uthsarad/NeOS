#!/bin/bash
# NeOS Automatic Update Script
# Creates snapshot before updates and handles rollback capability

set -euo pipefail

LOG_FILE="/var/log/neos-autoupdate.log"
LOCK_FILE="/run/neos-autoupdate.lock"

# Sentinel: Security Check - Ensure log file is not a symlink
# This prevents potential privilege escalation if /var/log permissions are compromised
if [ -L "$LOG_FILE" ]; then
    echo "ERROR: Log file is a symlink! Possible security attack." >&2
    exit 1
fi

# Log function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Sentinel: Prevent race conditions and DoS using flock
# Use /run for lock file as it's only writable by root, preventing user DoS
exec 9> "$LOCK_FILE"
if ! flock -n 9; then
    log "Update already running (lock held), exiting."
    exit 1
fi

# Sentinel: Dependency Check - Ensure snapper is installed
if ! command -v snapper &>/dev/null; then
    log "ERROR: snapper not found. Cannot perform snapshot-based updates."
    exit 1
fi

# Sentinel: Configuration Check - Ensure root is Btrfs
if ! findmnt -n -o FSTYPE / | grep -q "btrfs"; then
    log "ERROR: Root filesystem is not Btrfs. Cannot perform snapshot-based updates."
    exit 1
fi

# Create pre-update snapshot
log "Creating pre-update snapshot..."
PRE_SNAP_ID=$(snapper --config=root create --type pre --cleanup-algorithm timeline --print-number --description "Pre-automatic-update-$(date +%Y%m%d_%H%M%S)")
log "Pre-update snapshot created: $PRE_SNAP_ID"

# Run system update
log "Starting system update..."
if pacman -Syu --noconfirm; then
    log "System update completed successfully"
    
    # Create post-update snapshot
    POST_SNAP_ID=$(snapper --config=root create --type post --cleanup-algorithm timeline --pre-number "$PRE_SNAP_ID" --print-number --description "Post-automatic-update-$(date +%Y%m%d_%H%M%S)")
    log "Post-update snapshot created: $POST_SNAP_ID"
    
    # Optionally clean old snapshots (keep last 10)
    log "Cleaning old snapshots..."
    snapper --config=root cleanup number
    
    log "Automatic update process completed successfully"
else
    log "System update failed, attempting rollback to snapshot $PRE_SNAP_ID"
    
    # Attempt rollback to pre-update snapshot
    if snapper rollback "$PRE_SNAP_ID"; then
        log "Rollback to snapshot $PRE_SNAP_ID successful, system requires reboot"
        # Schedule reboot after delay to allow for notification
        shutdown -r +1 "NeOS automatic update failed, rolled back to previous state. Rebooting in 1 minute."
    else
        log "Rollback failed, manual intervention required"
        exit 1
    fi
    
    exit 1
fi
