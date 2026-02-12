#!/bin/bash
# NeOS Automatic Update Script
# Creates snapshot before updates and handles rollback capability

set -euo pipefail

LOG_FILE="/var/log/neos-autoupdate.log"
LOCK_FILE="/run/neos-autoupdate.lock"

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

# Create pre-update snapshot
log "Creating pre-update snapshot..."
PRE_SNAP_NUM=$(snapper --config=root create --type pre --cleanup-algorithm timeline --description "Pre-automatic-update-$(date +%Y%m%d_%H%M%S)")
PRE_SNAP_ID=$(echo "$PRE_SNAP_NUM" | grep "create:" | cut -d: -f2 | tr -d ' ')
log "Pre-update snapshot created: $PRE_SNAP_ID"

# Run system update
log "Starting system update..."
if pacman -Syu --noconfirm; then
    log "System update completed successfully"
    
    # Create post-update snapshot
    POST_SNAP_NUM=$(snapper --config=root create --type post --cleanup-algorithm timeline --pre-number "$PRE_SNAP_ID" --description "Post-automatic-update-$(date +%Y%m%d_%H%M%S)")
    POST_SNAP_ID=$(echo "$POST_SNAP_NUM" | grep "create:" | cut -d: -f2 | tr -d ' ')
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