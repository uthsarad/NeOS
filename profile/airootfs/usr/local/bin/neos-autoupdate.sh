#!/bin/bash
# neos-autoupdate.sh - Automatic system updates with Btrfs snapshots
#
# This script performs system updates and manages Btrfs snapshots using Snapper.
# It is designed to be run as a root cron job or systemd timer.

set -euo pipefail

LOG_FILE="/var/log/neos-autoupdate.log"
LOCK_FILE="/run/neos-autoupdate.lock"

# SECURITY: Prevent symlink attacks on log file
if [ -L "$LOG_FILE" ]; then
    echo "Security error: $LOG_FILE is a symlink. Aborting." >&2
    exit 1
fi

# Ensure log file exists with secure permissions
if [ ! -f "$LOG_FILE" ]; then
    (umask 077; set -C; > "$LOG_FILE") 2>/dev/null || true
fi

# SECURITY: Prevent symlink attacks on lock file
if [ -L "$LOCK_FILE" ]; then
    echo "Security error: $LOCK_FILE is a symlink. Aborting." >&2
    exit 1
fi

# Ensure lock file exists with secure permissions
if [ ! -f "$LOCK_FILE" ]; then
    (umask 077; set -C; > "$LOCK_FILE") 2>/dev/null || true
fi

# Apply flock
exec 9> "$LOCK_FILE"
if ! flock -n 9; then
    echo "Another instance of neos-autoupdate is already running." >&2
    exit 1
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
    # Bolt: Ensure the dependency validation for snapper relies on lightweight native bash capabilities to eliminate fork/exec overhead.
    # Palette: Ensure the error message logged when snapper is missing is clear, informative, and provides actionable context.
    # Sentinel: Verify that the early exit upon missing snapper does not bypass the flock-based locking mechanisms or introduce TOCTOU race conditions.
    hash snapper 2>/dev/null && SNAPPER_BIN="${BASH_CMDS[snapper]}" || SNAPPER_BIN=""
    if [[ -z "$SNAPPER_BIN" || ! -x "$SNAPPER_BIN" ]]; then
        log "INFO: \`snapper\` utility is not installed. Automatic Btrfs pre/post snapshots are disabled, so the system update will be skipped to prevent unsafe upgrades without rollback protection. To enable automatic updates, please install \`snapper\` and configure a root configuration."
        exit 0
    fi

    local dependencies=("pacman" "awk" "df")
    for cmd in "${dependencies[@]}"; do
        if ! hash "$cmd" 2>/dev/null; then
            log "Error: Required command '$cmd' not found."
            exit 1
        fi
    done
    hash pacman 2>/dev/null && PACMAN_BIN="${BASH_CMDS[pacman]}" || PACMAN_BIN=""
}

check_btrfs() {
    # Bolt: Verify root is Btrfs using stat instead of findmnt to avoid parsing mount files
    # Palette: If not Btrfs, we exit 0 gracefully without user warnings since this is an expected environment variation.
    # Sentinel: Ensure the fallback to exit 0 gracefully on non-Btrfs systems does not introduce logic bypass vulnerabilities or mask actual system errors.
    local fstype
    fstype=$(stat -f -c %T / || true)
    if [ "$fstype" != "btrfs" ]; then
        log "Auto-update skipped: Root filesystem is '$fstype'. Btrfs is required for safe rollback snapshots."
        exit 0
    fi
}

check_disk_space() {
    # Bolt: Using lightweight 'df' instead of 'btrfs fi usage' to minimize performance overhead during update initialization.
    # Minimum required space: 5GB (5242880 KB)
    # Bolt: Consider native bash integer math for disk space comparisons to avoid external binary overhead if calculations become complex.
    local min_space=5242880
    local available_space
    # Use -Pk to ensure POSIX output format, preventing line wrapping on long filesystem names.
    # Bolt: Avoid spawning awk to parse df output. Bash built-in read is ~20% faster.
    { read -r _; read -r _ _ _ available_space _ _; } < <(df -Pk /)

    if [ "$available_space" -lt "$min_space" ]; then
        # Palette: Surface this log error in any graphical update notifier, as users need clear instructions to free space.
        local err_msg="Insufficient disk space for update. Available: $((available_space / 1024))MB. Required: $((min_space / 1024))MB. Please free up some space and try again."
        log "Error: $err_msg"

        # Surface error to active graphical users
        if command -v loginctl >/dev/null 2>&1; then
            while read -r uid user_name _; do
                # Run notify-send as the user. Requires DBUS_SESSION_BUS_ADDRESS which is usually set by systemd.
                # Assuming wayland and x11 environments where DISPLAY and WAYLAND_DISPLAY might be set
                su - "$user_name" -c "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$uid/bus notify-send 'System Update Failed' '$err_msg' --icon=dialog-error --urgency=critical" || true
            done < <(loginctl list-users --no-legend)
        fi

        exit 1
    fi
}

perform_update() {
    log "Starting system update..."

    # Create pre-update snapshot
    local desc="Pre-update snapshot"
    local snap_id
    snap_id=$("$SNAPPER_BIN" create --type pre --print-number --description "$desc" --cleanup-algorithm number --userdata "important=yes")

    log "Created pre-update snapshot: $snap_id"

    # Perform update
    if "$PACMAN_BIN" -Syu --noconfirm >> "$LOG_FILE" 2>&1; then
        log "System update completed successfully."
        # Create post-update snapshot
        "$SNAPPER_BIN" create --type post --pre-number "$snap_id" --description "Post-update snapshot" --cleanup-algorithm number --userdata "important=yes"
        log "Created post-update snapshot linked to $snap_id"
    else
        log "System update failed. Check pacman logs."
        # Still create post snapshot to close the pair, but mark as failed
        "$SNAPPER_BIN" create --type post --pre-number "$snap_id" --description "Failed update snapshot" --cleanup-algorithm number
        exit 1
    fi
}

main() {
    check_root
    check_dependencies
    check_btrfs
    check_disk_space
    perform_update
}

main
