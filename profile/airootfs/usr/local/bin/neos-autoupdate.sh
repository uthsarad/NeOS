#!/bin/bash
# neos-autoupdate.sh - Automatic system updates with Btrfs snapshots
#
# This script performs system updates and manages Btrfs snapshots using Snapper.
# It is designed to be run as a root cron job or systemd timer.

set -euo pipefail

# Sentinel: [Security] Enforce strict PATH to prevent path hijacking
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"


# Sentinel: [Security] Sanitize script name for safe logging to prevent log injection
SCRIPT_NAME="${0##*/}"
SCRIPT_NAME="${SCRIPT_NAME//[^a-zA-Z0-9_.-]/}"

_error_handler() {
    local err=$1
    local line=$2
    local cmd="${BASH_COMMAND//[^[:print:]]/}"
    printf -- "\n\e[1m\e[31m================================================================================\e[0m\n\e[1m\e[31m🚨 CRITICAL ERROR: %s\e[0m\n\e[1m\e[31m================================================================================\e[0m\n\e[1m\e[36m💡 What went wrong:\e[0m\n  Command: \"%s\"\n  Failed at line: %s\n  Exit code: %s\n\n\e[1m\e[36m🔧 How to fix:\e[0m\n  1. Review system journal: \e[1mjournalctl -t neos-%s\e[0m\n  2. Check system state and script configuration.\n\e[1m\e[31m================================================================================\e[0m\n\n" "$SCRIPT_NAME" "$cmd" "$line" "$err" "$SCRIPT_NAME" >&2 || true
    logger -t "neos-$SCRIPT_NAME" "CRITICAL: Script failed at line $line (Exit Code $err). Command: \"$cmd\". Please review the system journal." || true
    exit "$err"
}

# Sentinel: Verify that trap commands safely handle variable expansion without introducing command injection risks. Ensure TOCTOU vulnerabilities are not introduced during file creation or logging.
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
    (umask 077; set -C; true > "$LOG_FILE") 2>/dev/null || true
fi

# SECURITY: Enforce ownership and permissions
chown root:root "$LOG_FILE"
chmod 600 "$LOG_FILE"

# SECURITY: Prevent symlink attacks on lock file
if [[ -L "$LOCK_FILE" ]]; then
    echo "Security error: $LOCK_FILE is a symlink. Aborting." >&2
    exit 1
fi

# Ensure lock file exists with secure permissions
if [[ ! -f "$LOCK_FILE" ]]; then
    (umask 077; set -C; true > "$LOCK_FILE") 2>/dev/null || true
fi

# SECURITY: Enforce ownership and permissions
chown root:root "$LOCK_FILE"
chmod 600 "$LOCK_FILE"

# Apply flock
exec 9> "$LOCK_FILE"
if ! flock -n 9; then
    echo "Another instance of neos-autoupdate is already running." >&2
    exit 1
fi

# Validate dependencies
# Bolt: Ensure the dependency validation for snapper relies on lightweight native bash capabilities to eliminate fork/exec overhead.
# Palette: Ensure the error message logged when snapper is missing is clear, informative, and provides actionable context.
# Sentinel: Verify that the early exit upon missing snapper does not bypass the flock-based locking mechanisms or introduce TOCTOU race conditions.
if ! command -v snapper >/dev/null 2>&1; then
    logger -t neos-autoupdate "INFO: 'snapper' utility is missing. System update skipped to prevent unsafe upgrades without rollback protection. Action: Install 'snapper' and configure a root profile."
    exit 0
fi

# Check for Btrfs root
# Bolt: Optimized Btrfs check using stat instead of findmnt | grep to eliminate subprocess overhead
if [[ "$(stat -f -c %T / 2>/dev/null)" != "btrfs" ]]; then
    logger -t neos-autoupdate "INFO: Auto-update skipped: Root filesystem is not Btrfs. Btrfs is required for safe rollback snapshots."
    exit 0
fi

log() {
    # Bolt: Use native bash printf for date formatting to eliminate fork/exec overhead
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

    # Sentinel: Strip single quotes from all variables to prevent command injection in su -c
    err_msg="${err_msg//\'/}"
    title="${title//\'/}"
    icon="${icon//\'/}"
    urgency="${urgency//\'/}"
    if command -v loginctl >/dev/null 2>&1; then
        while read -r uid user_name _; do
            # Run notify-send as the user. Requires DBUS_SESSION_BUS_ADDRESS which is usually set by systemd.
            # Assuming wayland and x11 environments where DISPLAY and WAYLAND_DISPLAY might be set
            su - "$user_name" -c "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$uid/bus notify-send '$title' '$err_msg' --icon='$icon' --urgency='$urgency'" || true
        done < <(loginctl list-users --no-legend)
    fi
}

check_root() {
    if (( EUID != 0 )); then
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
        local err_msg="INFO: \`snapper\` utility is not installed. Automatic Btrfs pre/post snapshots are disabled, so the system update will be skipped to prevent unsafe upgrades without rollback protection. To enable automatic updates, please install \`snapper\` and configure a root configuration."
        log "$err_msg"
        notify_users "$err_msg" "System Update Skipped" "dialog-information" "normal"
        exit 0
    fi

    local dependencies=("pacman" "df")
    for cmd in "${dependencies[@]}"; do
        if ! hash "$cmd" 2>/dev/null; then
            local err_msg="Required command \`$cmd\` not found.

Please install the package containing \`$cmd\` to enable automatic system updates."
            log "Error: Required command \`$cmd\` not found."
            notify_users "$err_msg" "Update Failed: Missing Dependency" "dialog-error" "critical"
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
    if [[ "$fstype" != "btrfs" ]]; then
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

    if (( available_space < min_space )); then
        # Palette: Surface this log error in any graphical update notifier, as users need clear instructions to free space.
        local err_msg="Insufficient disk space for update.

Available: $((available_space / 1024)) MB
Required: $((min_space / 1024)) MB

Please free up some space and try again."
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

    log "Created pre-update snapshot: $snap_id"

    # Perform update
    if "$PACMAN_BIN" -Syu --noconfirm >> "$LOG_FILE" 2>&1; then
        log "System update completed successfully."
        # Create post-update snapshot
        "$SNAPPER_BIN" create --type post --pre-number "$snap_id" --description "Post-update snapshot" --cleanup-algorithm number --userdata "important=yes"
        log "Created post-update snapshot linked to $snap_id"
    else
        local err_msg="The system update failed during execution.

Please review the update logs for more details:
<b>/var/log/neos-autoupdate.log</b>"
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
