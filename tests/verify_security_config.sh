#!/bin/bash
set -e

CONFIG_FILE="profile/airootfs/etc/sysctl.d/90-neos-security.conf"

echo "Verifying security configuration in $CONFIG_FILE..."

# Check for fs.protected_hardlinks
CONFIG_CONTENT=$(<"$CONFIG_FILE")

if [[ "$CONFIG_CONTENT" == *"fs.protected_hardlinks = 1"* ]]; then
    echo "  [PASS] fs.protected_hardlinks found"
else
    echo "[FAIL] fs.protected_hardlinks NOT found"
    exit 1
fi

# Check for fs.protected_symlinks
if [[ "$CONFIG_CONTENT" == *"fs.protected_symlinks = 1"* ]]; then
    echo "  [PASS] fs.protected_symlinks found"
else
    echo "[FAIL] fs.protected_symlinks NOT found"
    exit 1
fi

# Check for kernel.unprivileged_bpf_disabled
if [[ "$CONFIG_CONTENT" == *"kernel.unprivileged_bpf_disabled = 1"* ]]; then
    echo "  [PASS] kernel.unprivileged_bpf_disabled found"
else
    echo "[FAIL] kernel.unprivileged_bpf_disabled NOT found"
    exit 1
fi

# Check for net.ipv4.tcp_syncookies
if [[ "$CONFIG_CONTENT" == *"net.ipv4.tcp_syncookies = 1"* ]]; then
    echo "  [PASS] net.ipv4.tcp_syncookies found"
else
    echo "[FAIL] net.ipv4.tcp_syncookies NOT found"
    exit 1
fi

# Check for net.ipv4.conf.all.rp_filter
if [[ "$CONFIG_CONTENT" == *"net.ipv4.conf.all.rp_filter = 1"* ]]; then
    echo "  [PASS] net.ipv4.conf.all.rp_filter found"
else
    echo "[FAIL] net.ipv4.conf.all.rp_filter NOT found"
    exit 1
fi

# Check for net.ipv4.icmp_echo_ignore_broadcasts
if [[ "$CONFIG_CONTENT" == *"net.ipv4.icmp_echo_ignore_broadcasts = 1"* ]]; then
    echo "  [PASS] net.ipv4.icmp_echo_ignore_broadcasts found"
else
    echo "[FAIL] net.ipv4.icmp_echo_ignore_broadcasts NOT found"
    exit 1
fi

# Check for net.ipv4.conf.all.accept_source_route
if [[ "$CONFIG_CONTENT" == *"net.ipv4.conf.all.accept_source_route = 0"* ]]; then
    echo "  [PASS] net.ipv4.conf.all.accept_source_route found"
else
    echo "[FAIL] net.ipv4.conf.all.accept_source_route NOT found"
    exit 1
fi

# Check for net.ipv4.tcp_rfc1337
if [[ "$CONFIG_CONTENT" == *"net.ipv4.tcp_rfc1337 = 1"* ]]; then
    echo "  [PASS] net.ipv4.tcp_rfc1337 found"
else
    echo "[FAIL] net.ipv4.tcp_rfc1337 NOT found"
    exit 1
fi

# Check for kernel.sysrq (176 = safe subset: sync+remount-ro+reboot for emergency recovery)
if [[ "$CONFIG_CONTENT" =~ kernel\.sysrq\ =\ (0|176) ]]; then
    echo "  [PASS] kernel.sysrq found"
else
    echo "[FAIL] kernel.sysrq NOT found"
    exit 1
fi

# Check for kernel.core_uses_pid
if [[ "$CONFIG_CONTENT" == *"kernel.core_uses_pid = 1"* ]]; then
    echo "  [PASS] kernel.core_uses_pid found"
else
    echo "[FAIL] kernel.core_uses_pid NOT found"
    exit 1
fi

if [[ "$CONFIG_CONTENT" =~ fs\.suid_dumpable\ =\ [0-2] ]]; then
    echo "  [PASS] fs.suid_dumpable found"
else
    echo "[FAIL] fs.suid_dumpable NOT found"
    exit 1
fi

if [[ "$CONFIG_CONTENT" == *"dev.tty.ldisc_autoload = 0"* ]]; then
    echo "  [PASS] dev.tty.ldisc_autoload found"
else
    echo "[FAIL] dev.tty.ldisc_autoload NOT found"
    exit 1
fi

if [[ "$CONFIG_CONTENT" == *"vm.unprivileged_userfaultfd = 0"* ]]; then
    echo "  [PASS] vm.unprivileged_userfaultfd found"
else
    echo "[FAIL] vm.unprivileged_userfaultfd NOT found"
    exit 1
fi

if [[ "$CONFIG_CONTENT" == *"kernel.perf_event_paranoid = 3"* ]]; then
    echo "  [PASS] kernel.perf_event_paranoid found"
else
    echo "[FAIL] kernel.perf_event_paranoid NOT found"
    exit 1
fi

# The installed-system pacman.conf must require signed PACKAGES but keep the
# database signature OPTIONAL. Arch's official repos (core/extra/multilib) do
# not sign their databases, so 'DatabaseRequired' makes pacman 404 on
# core.db.sig and every install (pacstrap) fails to sync databases.
PACMAN_CONF="profile/airootfs/etc/pacman.conf"
echo "Verifying security configuration in $PACMAN_CONF..."

if grep -qE "^SigLevel\s*=\s*Required\s+DatabaseOptional" "$PACMAN_CONF"; then
    echo "  [PASS] SigLevel = Required DatabaseOptional found"
elif grep -qE "^SigLevel\s*=\s*Required\s+DatabaseRequired" "$PACMAN_CONF"; then
    echo "[FAIL] SigLevel = Required DatabaseRequired in $PACMAN_CONF — official repos do not sign databases, this breaks installs. Use DatabaseOptional."
    exit 1
else
    echo "[FAIL] SigLevel must be 'Required DatabaseOptional' in $PACMAN_CONF (require signed packages, optional db sig)"
    exit 1
fi

ROOT_PACMAN_CONF="profile/pacman.conf"
echo "Verifying security configuration in $ROOT_PACMAN_CONF..."

# Root pacman.conf is used during ISO build and uses DatabaseOptional to support mirrors without .db.sig
if grep -qE "^SigLevel\s*=\s*Required\s+DatabaseOptional" "$ROOT_PACMAN_CONF"; then
    echo "[PASS] SigLevel = Required DatabaseOptional found in root pacman.conf"
else
    echo "[FAIL] SigLevel = Required DatabaseOptional NOT found in $ROOT_PACMAN_CONF"
    exit 1
fi

# We use grep -v "^#" to ignore comments
if grep -v "^#" "$ROOT_PACMAN_CONF" | grep -q "TrustAll"; then
    echo "[FAIL] TrustAll found in active configuration of $ROOT_PACMAN_CONF - This is insecure!"
    exit 1
else
    echo "  [PASS] TrustAll NOT found in active configuration of $ROOT_PACMAN_CONF (secure)"
fi

# The generation logic lives in tools/gen-build-conf.sh (shared by build.sh
# and CI); build.sh must call it.
BUILD_SCRIPT="build.sh"
GEN_CONF_SCRIPT="tools/gen-build-conf.sh"
echo "Verifying security configuration in $BUILD_SCRIPT / $GEN_CONF_SCRIPT..."

if grep -q "gen-build-conf.sh" "$BUILD_SCRIPT" \
    && grep -q "cp \"\$PROFILE_DIR/pacman.conf\" \"\$BUILD_CONF\"" "$GEN_CONF_SCRIPT"; then
    echo "  [PASS] build path uses repo pacman.conf (via $GEN_CONF_SCRIPT)"
else
    echo "[FAIL] build path does NOT use repo pacman.conf"
    exit 1
fi

USERS_CONF="profile/airootfs/etc/calamares/modules/users.conf"
echo "Verifying user groups in $USERS_CONF..."

if [ -f "$USERS_CONF" ]; then
    if grep -q "defaultGroups:" "$USERS_CONF" && grep -q "wheel" "$USERS_CONF"; then
        UNSAFE_GROUPS=("sys" "lp" "network" "optical" "scanner" "adm" "uucp")
        UNSAFE_PATTERN="[[:space:]]- ($(IFS=\|; echo "${UNSAFE_GROUPS[*]}"))"
        UNSAFE_FOUND=false

        while read -r match; do
            if [ -n "$match" ]; then
                # Extract the group name from the match (e.g. "  - sys" -> "sys")
                group="${match##*- }"
                echo "[FAIL] Unsafe group '$group' found in $USERS_CONF"
                UNSAFE_FOUND=true
            fi
        done < <(grep -E -o "$UNSAFE_PATTERN" "$USERS_CONF" || true)

        if [ "$UNSAFE_FOUND" = true ]; then
            exit 1
        else
            echo "  [PASS] User groups configuration is secure"
        fi
    else
        echo "[FAIL] defaultGroups or wheel not found in $USERS_CONF"
        exit 1
    fi
else
    echo "[WARN] $USERS_CONF not found, skipping check."
fi

echo "All security checks passed!"
