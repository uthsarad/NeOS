#!/bin/bash
# neos-autoupdate.sh - Automatic system updates with Btrfs snapshots
#
# This script performs system updates and manages Btrfs snapshots using Snapper.
# It is designed to be run as a root cron job or systemd timer.

set -euo pipefail

# Restrictive umask: the log and lock files below rely on it (root-only).
umask 077

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export TMPDIR="/var/tmp" # Enforce secure temporary file handling defaults


SCRIPT_NAME="${0##*/}"
SCRIPT_NAME="${SCRIPT_NAME//[^a-zA-Z0-9_.-]/}"

_error_handler() {
    local err=$1
    local line=$2
    local cmd="${BASH_COMMAND//[^[:print:]]/}"
    printf -- "\n\e[1m\e[31m================================================================================\e[0m\n\e[1m\e[31m[CRITICAL] [%s] SCRIPT FAILURE\e[0m\n\e[1m\e[31m================================================================================\e[0m\n\e[1m\e[36m[DIAGNOSTICS]:\e[0m\n  • Failed Command: \"%s\"\n  • File / Line:    %s:%s\n  • Exit Status:    %s\n\n\e[1m\e[36m[ACTIONABLE STEPS]:\e[0m\n  1. Inspect the system journal for detailed logs:\n     \e[1mjournalctl -t neos-%s -n 50 --no-pager\e[0m\n  2. Verify system state, permissions, and script configuration.\n\e[1m\e[31m================================================================================\e[0m\n\n" "$SCRIPT_NAME" "$cmd" "$SCRIPT_NAME" "$line" "$err" "$SCRIPT_NAME" >&2 || true
    logger -t "neos-$SCRIPT_NAME" "CRITICAL: Script failed at line $line (Exit Code $err). Command: \"$cmd\". Please review the system journal." || true
    exit "$err"
}

trap '_error_handler $? $LINENO' ERR

LOG_FILE="/var/log/neos-autoupdate.log"
LOCK_FILE="/run/neos-autoupdate.lock"

# SECURITY: Prevent symlink attacks on log file
if [[ -L "$LOG_FILE" ]]; then
    echo "Security error: $LOG_FILE is a symlink. Aborting." >&2
    exit 1
fi

# Ensure log file exists with secure permissions
if [[ ! -f "$LOG_FILE" ]]; then
    (set -C; true > "$LOG_FILE") 2>/dev/null || true
fi

# umask 077 covers files created above; tighten one left by an older version.
# (The symlink check above, and root-only /var/log and /run, rule out a swap.)
chmod 600 -- "$LOG_FILE" 2>/dev/null || true

# SECURITY: Prevent symlink attacks on lock file
if [[ -L "$LOCK_FILE" ]]; then
    echo "Security error: $LOCK_FILE is a symlink. Aborting." >&2
    exit 1
fi

# Ensure lock file exists with secure permissions
if [[ ! -f "$LOCK_FILE" ]]; then
    (set -C; true > "$LOCK_FILE") 2>/dev/null || true
fi

chmod 600 -- "$LOCK_FILE" 2>/dev/null || true

# Apply flock
exec 9> "$LOCK_FILE"
if ! flock -n 9; then
    echo "Another instance of neos-autoupdate is already running." >&2
    exit 1
fi

# Validate dependencies
if ! command -v snapper >/dev/null 2>&1; then
    logger -t neos-autoupdate "INFO: 'snapper' utility is missing. System update skipped to prevent unsafe upgrades without rollback protection. Action: Install 'snapper' and configure a root profile."
    exit 0
fi

# Check for Btrfs root
if [[ "$(stat -f -c %T / 2>/dev/null)" != "btrfs" ]]; then
    logger -t neos-autoupdate "INFO: Auto-update skipped: Root filesystem is not Btrfs. Btrfs is required for safe rollback snapshots."
    exit 0
fi

log() {
    local msg
    printf -v msg '%(%Y-%m-%d %H:%M:%S)T - %s\n' -1 "$1"
    printf "%s" "$msg"
    printf "%s" "$msg" >> "$LOG_FILE"
}

notify_users() {
    local err_msg="$1"
    local title="${2:-System Update Failed}"
    local icon="${3:-dialog-error}"
    local urgency="${4:-critical}"

    if ! command -v loginctl >/dev/null 2>&1 || ! command -v notify-send >/dev/null 2>&1; then
        return 0
    fi

    while read -r uid user_name _; do
        # Sentinel: Sanitize inputs to prevent argument injection
        uid="${uid//[^0-9]/}"
        user_name="${user_name//[^a-zA-Z0-9_.-]/}"
        if [[ -z "$uid" || -z "$user_name" ]]; then continue; fi

        # Sentinel: Enforce safe execution boundary using -- and env
        sudo -u "$user_name" -- env DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$uid/bus" \
            notify-send -- "$title" "$err_msg" --icon="$icon" --urgency="$urgency" || true
    done < <(loginctl list-users --no-legend)
}

check_root() {
    if (( EUID != 0 )); then
        echo "This script must be run as root." >&2
        exit 1
    fi
}

check_dependencies() {
    hash snapper 2>/dev/null && SNAPPER_BIN="${BASH_CMDS[snapper]}" || SNAPPER_BIN=""
    if [[ -z "$SNAPPER_BIN" || ! -x "$SNAPPER_BIN" ]]; then
        local err_msg="Automatic updates are paused because <b>snapper</b> is missing.

Without it, NeOS cannot create safety snapshots to protect your system.

<b>How to fix:</b>
1. Install the snapper package.
2. Configure a root snapshot profile."
        local log_msg="INFO: 'snapper' utility is not installed. Automatic Btrfs pre/post snapshots are disabled, so the system update will be skipped to prevent unsafe upgrades without rollback protection. To enable automatic updates, please install 'snapper' and configure a root configuration."
        log "$log_msg"
        notify_users "$err_msg" "System Update Skipped" "dialog-information" "normal"
        exit 0
    fi

    local dependencies=("pacman" "df")
    for cmd in "${dependencies[@]}"; do
        if ! hash "$cmd" 2>/dev/null; then
            local err_msg="The system update requires <b>$cmd</b>, which is missing.

<b>How to fix:</b>
Please install the package containing <b>$cmd</b> to resume automatic updates."
            log "Error: Required command '$cmd' not found."
            notify_users "$err_msg" "Update Failed: Missing Dependency" "dialog-error" "critical"
            exit 1
        fi
    done
    hash pacman 2>/dev/null && PACMAN_BIN="${BASH_CMDS[pacman]}" || PACMAN_BIN=""
}

check_btrfs() {
    local fstype
    fstype=$(stat -f -c %T / || true)
    if [[ "$fstype" != "btrfs" ]]; then
        log "Auto-update skipped: Root filesystem is '$fstype'. Btrfs is required for safe rollback snapshots."
        exit 0
    fi
}

check_disk_space() {
    # Minimum required space: 5GB (5242880 KB)
    local min_space=5242880
    local available_space
    # Use -Pk to ensure POSIX output format, preventing line wrapping on long filesystem names.
    { read -r _; read -r _ _ _ available_space _ _; } < <(df -Pk /)

    if (( available_space < min_space )); then
        local err_msg="The system update requires more disk space.

<b>Available:</b> $((available_space / 1024)) MB
<b>Required:</b> $((min_space / 1024)) MB

<b>How to fix:</b>
Please free up some disk space to continue."
        log "Error: Insufficient disk space. Available: $((available_space / 1024))MB. Required: $((min_space / 1024))MB."
        notify_users "$err_msg" "Update Failed: Disk Full" "drive-harddisk" "critical"

        exit 1
    fi
}

perform_update() {
    log "Starting system update..."

    # Create pre-update snapshot
    local desc="Pre-update snapshot"
    local snap_id
    snap_id=$("$SNAPPER_BIN" create --type pre --print-number --description "$desc" --cleanup-algorithm number --userdata "important=yes")
    # Sentinel: Sanitize snap_id to prevent injection on subsequent calls
    snap_id="${snap_id//[^0-9]/}"
    if [[ -z "$snap_id" ]]; then
        log "Error: Invalid or missing snapshot ID."
        exit 1
    fi

    log "Created pre-update snapshot: $snap_id"

    # Perform update
    if "$PACMAN_BIN" -Syu --noconfirm >> "$LOG_FILE" 2>&1; then
        log "System update completed successfully."
        notify_users "Your system has been successfully updated to the latest version." "System Update Complete" "system-software-update" "normal"
        # Create post-update snapshot
        "$SNAPPER_BIN" create --type post --pre-number "$snap_id" --description "Post-update snapshot" --cleanup-algorithm number --userdata "important=yes"
        log "Created post-update snapshot linked to $snap_id"
    else
        local err_msg="The system update encountered an error.

<b>How to investigate:</b>
Please review the logs at <b>/var/log/neos-autoupdate.log</b> for more details."
        log "System update failed. Check pacman logs."
        notify_users "$err_msg" "System Update Failed" "dialog-error" "critical"
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
