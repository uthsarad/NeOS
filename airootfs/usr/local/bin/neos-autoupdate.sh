#!/bin/bash
# neos-autoupdate.sh - Automatic system updates with Btrfs snapshots
#
# This script performs system updates and manages Btrfs snapshots using Snapper.
# It is designed to be run as a root cron job or systemd timer.

set -euo pipefail

LOG_FILE="/var/log/neos-autoupdate.log"

# SECURITY: Prevent symlink attacks on log file
if [ -L "$LOG_FILE" ]; then
    echo "Security error: $LOG_FILE is a symlink. Aborting." >&2
    exit 1
fi

# Ensure log file exists with secure permissions
if [ ! -f "$LOG_FILE" ]; then
    (umask 077; set -C; > "$LOG_FILE") 2>/dev/null || true
    chmod 600 "$LOG_FILE"
fi

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "This script must be run as root." >&2
        exit 1
    fi
}

check_dependencies() {
    local dependencies=("snapper" "pacman" "awk" "df")
    for cmd in "${dependencies[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            log "Error: Required command '$cmd' not found."
            exit 1
        fi
    done
}

check_disk_space() {
    # Bolt: Using lightweight 'df' instead of 'btrfs fi usage' to minimize performance overhead during update initialization.
    # Minimum required space: 5GB (5242880 KB)
    local min_space=5242880
    local available_space
    # Use -Pk to ensure POSIX output format, preventing line wrapping on long filesystem names.
    available_space=$(df -Pk / | awk 'NR==2 {print $4}')

    if [ "$available_space" -lt "$min_space" ]; then
        # Palette: Surface this log error in any graphical update notifier, as users need clear instructions to free space.
        local err_msg="Insufficient disk space for update. Available: $((available_space / 1024))MB. Required: $((min_space / 1024))MB. Please free up some space and try again."
        log "Error: $err_msg"

        # Surface error to active graphical users
        if command -v loginctl >/dev/null 2>&1; then
            for uid in $(loginctl list-sessions --no-legend | awk '{print $2}' | sort -u); do
                local user_name
                user_name=$(id -nu "$uid")
                # Run notify-send as the user. Requires DBUS_SESSION_BUS_ADDRESS which is usually set by systemd.
                # Assuming wayland and x11 environments where DISPLAY and WAYLAND_DISPLAY might be set
                su - "$user_name" -c "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$uid/bus notify-send 'System Update Failed' '$err_msg' --icon=dialog-error --urgency=critical" || true
            done
        fi

        exit 1
    fi
}

perform_update() {
    log "Starting system update..."

    # Create pre-update snapshot
    local desc="Pre-update snapshot"
    local snap_id
    snap_id=$(snapper create --type pre --print-number --description "$desc" --cleanup-algorithm number --userdata "important=yes")

    log "Created pre-update snapshot: $snap_id"

    # Perform update
    if pacman -Syu --noconfirm >> "$LOG_FILE" 2>&1; then
        log "System update completed successfully."
        # Create post-update snapshot
        snapper create --type post --pre-number "$snap_id" --description "Post-update snapshot" --cleanup-algorithm number --userdata "important=yes"
        log "Created post-update snapshot linked to $snap_id"
    else
        log "System update failed. Check pacman logs."
        # Still create post snapshot to close the pair, but mark as failed
        snapper create --type post --pre-number "$snap_id" --description "Failed update snapshot" --cleanup-algorithm number
        exit 1
    fi
}

main() {
    check_root
    check_dependencies
    check_disk_space
    perform_update
}

main
