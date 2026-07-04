#!/bin/bash
set -e

CONFIG_FILE="profile/airootfs/etc/sysctl.d/90-neos-security.conf"

echo "Verifying security configuration in $CONFIG_FILE..."

# Check for fs.protected_hardlinks
if grep -q "fs.protected_hardlinks = 1" "$CONFIG_FILE"; then
    echo "✅ fs.protected_hardlinks found"
else
    echo "❌ fs.protected_hardlinks NOT found"
    exit 1
fi

# Check for fs.protected_symlinks
if grep -q "fs.protected_symlinks = 1" "$CONFIG_FILE"; then
    echo "✅ fs.protected_symlinks found"
else
    echo "❌ fs.protected_symlinks NOT found"
    exit 1
fi

# Check for kernel.unprivileged_bpf_disabled
if grep -q "kernel.unprivileged_bpf_disabled = 1" "$CONFIG_FILE"; then
    echo "✅ kernel.unprivileged_bpf_disabled found"
else
    echo "❌ kernel.unprivileged_bpf_disabled NOT found"
    exit 1
fi

# Check for net.ipv4.tcp_syncookies
if grep -q "net.ipv4.tcp_syncookies = 1" "$CONFIG_FILE"; then
    echo "✅ net.ipv4.tcp_syncookies found"
else
    echo "❌ net.ipv4.tcp_syncookies NOT found"
    exit 1
fi

# Check for net.ipv4.conf.all.rp_filter
if grep -q "net.ipv4.conf.all.rp_filter = 1" "$CONFIG_FILE"; then
    echo "✅ net.ipv4.conf.all.rp_filter found"
else
    echo "❌ net.ipv4.conf.all.rp_filter NOT found"
    exit 1
fi

# Check for net.ipv4.icmp_echo_ignore_broadcasts
if grep -q "net.ipv4.icmp_echo_ignore_broadcasts = 1" "$CONFIG_FILE"; then
    echo "✅ net.ipv4.icmp_echo_ignore_broadcasts found"
else
    echo "❌ net.ipv4.icmp_echo_ignore_broadcasts NOT found"
    exit 1
fi

# Check for net.ipv4.conf.all.accept_source_route
if grep -q "net.ipv4.conf.all.accept_source_route = 0" "$CONFIG_FILE"; then
    echo "✅ net.ipv4.conf.all.accept_source_route found"
else
    echo "❌ net.ipv4.conf.all.accept_source_route NOT found"
    exit 1
fi

# Check for net.ipv4.tcp_rfc1337
if grep -q "net.ipv4.tcp_rfc1337 = 1" "$CONFIG_FILE"; then
    echo "✅ net.ipv4.tcp_rfc1337 found"
else
    echo "❌ net.ipv4.tcp_rfc1337 NOT found"
    exit 1
fi

# Check for kernel.sysrq (176 = safe subset: sync+remount-ro+reboot for emergency recovery)
if grep -qE "kernel.sysrq = (0|176)" "$CONFIG_FILE"; then
    echo "✅ kernel.sysrq found"
else
    echo "❌ kernel.sysrq NOT found"
    exit 1
fi

# Check for kernel.core_uses_pid
if grep -q "kernel.core_uses_pid = 1" "$CONFIG_FILE"; then
    echo "✅ kernel.core_uses_pid found"
else
    echo "❌ kernel.core_uses_pid NOT found"
    exit 1
fi

# Sentinel: Check for fs.suid_dumpable (0 = disabled, most secure)
if grep -qE "fs.suid_dumpable = [0-2]" "$CONFIG_FILE"; then
    echo "✅ fs.suid_dumpable found"
else
    echo "❌ fs.suid_dumpable NOT found"
    exit 1
fi

# Sentinel: Check for dev.tty.ldisc_autoload
if grep -q "dev.tty.ldisc_autoload = 0" "$CONFIG_FILE"; then
    echo "✅ dev.tty.ldisc_autoload found"
else
    echo "❌ dev.tty.ldisc_autoload NOT found"
    exit 1
fi

# Sentinel: Check for vm.unprivileged_userfaultfd
if grep -q "vm.unprivileged_userfaultfd = 0" "$CONFIG_FILE"; then
    echo "✅ vm.unprivileged_userfaultfd found"
else
    echo "❌ vm.unprivileged_userfaultfd NOT found"
    exit 1
fi

# Sentinel: Check for kernel.perf_event_paranoid
if grep -q "kernel.perf_event_paranoid = 3" "$CONFIG_FILE"; then
    echo "✅ kernel.perf_event_paranoid found"
else
    echo "❌ kernel.perf_event_paranoid NOT found"
    exit 1
fi

# The installed-system pacman.conf must require signed PACKAGES but keep the
# database signature OPTIONAL. Arch's official repos (core/extra/multilib) do
# not sign their databases, so 'DatabaseRequired' makes pacman 404 on
# core.db.sig and every install (pacstrap) fails to sync databases.
PACMAN_CONF="profile/airootfs/etc/pacman.conf"
echo "Verifying security configuration in $PACMAN_CONF..."

if grep -qE "^SigLevel\s*=\s*Required\s+DatabaseOptional" "$PACMAN_CONF"; then
    echo "✅ SigLevel = Required DatabaseOptional found"
elif grep -qE "^SigLevel\s*=\s*Required\s+DatabaseRequired" "$PACMAN_CONF"; then
    echo "❌ SigLevel = Required DatabaseRequired in $PACMAN_CONF — official repos do not sign databases, this breaks installs. Use DatabaseOptional."
    exit 1
else
    echo "❌ SigLevel must be 'Required DatabaseOptional' in $PACMAN_CONF (require signed packages, optional db sig)"
    exit 1
fi

# Sentinel: Check for SigLevel = Required DatabaseOptional in root pacman.conf (build-time config)
ROOT_PACMAN_CONF="profile/pacman.conf"
echo "Verifying security configuration in $ROOT_PACMAN_CONF..."

# Root pacman.conf is used during ISO build and uses DatabaseOptional to support mirrors without .db.sig
if grep -qE "^SigLevel\s*=\s*Required\s+DatabaseOptional" "$ROOT_PACMAN_CONF"; then
    echo "✅ SigLevel = Required DatabaseOptional found in root pacman.conf"
else
    echo "❌ SigLevel = Required DatabaseOptional NOT found in $ROOT_PACMAN_CONF"
    exit 1
fi

# Sentinel: Check for unsafe TrustAll directive in root pacman.conf
# We use grep -v "^#" to ignore comments
if grep -v "^#" "$ROOT_PACMAN_CONF" | grep -q "TrustAll"; then
    echo "❌ TrustAll found in active configuration of $ROOT_PACMAN_CONF - This is insecure!"
    exit 1
else
    echo "✅ TrustAll NOT found in active configuration of $ROOT_PACMAN_CONF (secure)"
fi

# Sentinel: Check the build path uses the repo pacman.conf as its base.
# The generation logic lives in tools/gen-build-conf.sh (shared by build.sh
# and CI); build.sh must call it.
BUILD_SCRIPT="build.sh"
GEN_CONF_SCRIPT="tools/gen-build-conf.sh"
echo "Verifying security configuration in $BUILD_SCRIPT / $GEN_CONF_SCRIPT..."

if grep -q "gen-build-conf.sh" "$BUILD_SCRIPT" \
    && grep -q "cp \"\$PROFILE_DIR/pacman.conf\" \"\$BUILD_CONF\"" "$GEN_CONF_SCRIPT"; then
    echo "✅ build path uses repo pacman.conf (via $GEN_CONF_SCRIPT)"
else
    echo "❌ build path does NOT use repo pacman.conf"
    exit 1
fi

# Sentinel: Check for unsafe user groups in Calamares configuration
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
                echo "❌ Unsafe group '$group' found in $USERS_CONF"
                UNSAFE_FOUND=true
            fi
        done < <(grep -E -o "$UNSAFE_PATTERN" "$USERS_CONF" || true)

        if [ "$UNSAFE_FOUND" = true ]; then
            exit 1
        else
            echo "✅ User groups configuration is secure"
        fi
    else
        echo "❌ defaultGroups or wheel not found in $USERS_CONF"
        exit 1
    fi
else
    echo "⚠️ $USERS_CONF not found, skipping check."
fi

echo "All security checks passed!"
