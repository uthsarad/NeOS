#!/bin/bash
set -e

# --- Calamares Installer Config Verification ---
CONFIG_FILE="profile/airootfs/etc/calamares/modules/fstab.conf"

echo "Verifying performance configuration in $CONFIG_FILE..."

if [[ -f "$CONFIG_FILE" ]]; then
    # Check for space_cache=v2 in btrfs mount options
    # We expect it alongside compress=zstd to ensure it's in the main mountOptions block, not just ssdExtraMountOptions
    CONFIG_CONTENT=$(<"$CONFIG_FILE")
    if [[ "$CONFIG_CONTENT" =~ btrfs:[^\n]*compress=zstd:1[^\n]*discard=async[^\n]*space_cache=v2 ]]; then
        echo "✅ space_cache=v2 found in main Btrfs mount options"
    else
        echo "❌ space_cache=v2 NOT found in main Btrfs mount options (or not correctly placed)"
        # Show context for debugging
        grep "btrfs:" "$CONFIG_FILE" || true
        exit 1
    fi
else
    echo "⚠️ Calamares config not found ($CONFIG_FILE). Skipping Calamares performance checks."
fi

# --- System Performance Config Verification ---
SYSCTL_FILE="profile/airootfs/etc/sysctl.d/99-neos-performance.conf"

echo "Verifying sysctl performance configuration in $SYSCTL_FILE..."

if [[ ! -f "$SYSCTL_FILE" ]]; then
    echo "❌ Missing performance config file: $SYSCTL_FILE"
    exit 1
fi

SYSCTL_CONTENT=$(<"$SYSCTL_FILE")

# Verify vm.swappiness is SET TO 100 (ZRAM optimization)
if [[ "$SYSCTL_CONTENT" =~ (^|$'\n')vm\.swappiness[^\n]*=[^\n]*100 ]]; then
    echo "✅ vm.swappiness set to 100 (optimized for ZRAM)"
else
    echo "❌ vm.swappiness is NOT set to 100"
    grep "vm.swappiness" "$SYSCTL_FILE" || true
    exit 1
fi

# Verify vm.page-cluster is SET TO 0
if [[ "$SYSCTL_CONTENT" =~ (^|$'\n')vm\.page-cluster[^\n]*=[^\n]*0 ]]; then
    echo "✅ vm.page-cluster set to 0 (optimized for ZRAM)"
else
    echo "❌ vm.page-cluster is NOT set to 0"
    grep "vm.page-cluster" "$SYSCTL_FILE" || true
    exit 1
fi

# Verify vm.vfs_cache_pressure is SET TO 50
if [[ "$SYSCTL_CONTENT" =~ (^|$'\n')vm\.vfs_cache_pressure[^\n]*=[^\n]*50 ]]; then
    echo "✅ vm.vfs_cache_pressure set to 50 (optimized for responsiveness)"
else
    echo "❌ vm.vfs_cache_pressure is NOT set to 50"
    grep "vm.vfs_cache_pressure" "$SYSCTL_FILE" || true
    exit 1
fi

# Verify vm.max_map_count is SET TO 2147483642
if [[ "$SYSCTL_CONTENT" =~ (^|$'\n')vm\.max_map_count[^\n]*=[^\n]*2147483642 ]]; then
    echo "✅ vm.max_map_count set to 2147483642 (optimized for gaming)"
else
    echo "❌ vm.max_map_count is NOT set to 2147483642"
    grep "vm.max_map_count" "$SYSCTL_FILE" || true
    exit 1
fi

# Verify net.core.default_qdisc is SET TO cake
if [[ "$SYSCTL_CONTENT" =~ (^|$'\n')net\.core\.default_qdisc[^\n]*=[^\n]*cake ]]; then
    echo "✅ net.core.default_qdisc set to cake (bufferbloat mitigation)"
else
    echo "❌ net.core.default_qdisc is NOT set to cake"
    grep "net.core.default_qdisc" "$SYSCTL_FILE" || true
    exit 1
fi

# Verify net.ipv4.tcp_congestion_control is SET TO bbr
if [[ "$SYSCTL_CONTENT" =~ (^|$'\n')net\.ipv4\.tcp_congestion_control[^\n]*=[^\n]*bbr ]]; then
    echo "✅ net.ipv4.tcp_congestion_control set to bbr (congestion control)"
else
    echo "❌ net.ipv4.tcp_congestion_control is NOT set to bbr"
    grep "net.ipv4.tcp_congestion_control" "$SYSCTL_FILE" || true
    exit 1
fi

# Verify vm.dirty_ratio is SET TO 10
if [[ "$SYSCTL_CONTENT" =~ (^|$'\n')vm\.dirty_ratio[^\n]*=[^\n]*10 ]]; then
    echo "✅ vm.dirty_ratio set to 10 (optimized for I/O latency)"
else
    echo "❌ vm.dirty_ratio is NOT set to 10"
    grep "vm.dirty_ratio" "$SYSCTL_FILE" || true
    exit 1
fi

# Verify vm.dirty_background_ratio is SET TO 5
if [[ "$SYSCTL_CONTENT" =~ (^|$'\n')vm\.dirty_background_ratio[^\n]*=[^\n]*5 ]]; then
    echo "✅ vm.dirty_background_ratio set to 5 (optimized for I/O latency)"
else
    echo "❌ vm.dirty_background_ratio is NOT set to 5"
    grep "vm.dirty_background_ratio" "$SYSCTL_FILE" || true
    exit 1
fi

# Verify net.ipv4.tcp_fastopen is SET TO 3
if [[ "$SYSCTL_CONTENT" =~ (^|$'\n')net\.ipv4\.tcp_fastopen[^\n]*=[^\n]*3 ]]; then
    echo "✅ net.ipv4.tcp_fastopen set to 3"
else
    echo "❌ net.ipv4.tcp_fastopen is NOT set to 3"
    grep "net.ipv4.tcp_fastopen" "$SYSCTL_FILE" || true
    exit 1
fi

# Verify net.ipv4.tcp_slow_start_after_idle is SET TO 0
if [[ "$SYSCTL_CONTENT" =~ (^|$'\n')net\.ipv4\.tcp_slow_start_after_idle[^\n]*=[^\n]*0 ]]; then
    echo "✅ net.ipv4.tcp_slow_start_after_idle set to 0"
else
    echo "❌ net.ipv4.tcp_slow_start_after_idle is NOT set to 0"
    grep "net.ipv4.tcp_slow_start_after_idle" "$SYSCTL_FILE" || true
    exit 1
fi

# --- Network Modules Verification ---
MODULES_FILE="profile/airootfs/etc/modules-load.d/neos-networking.conf"
echo "Verifying network modules in $MODULES_FILE..."

if [[ ! -f "$MODULES_FILE" ]]; then
    echo "❌ Missing network modules file: $MODULES_FILE"
    exit 1
fi

MODULES_CONTENT=$(<"$MODULES_FILE")
if [[ "$MODULES_CONTENT" =~ (^|$'\n')tcp_bbr ]]; then
    echo "✅ tcp_bbr module enabled"
else
    echo "❌ tcp_bbr module NOT enabled"
    grep "tcp_bbr" "$MODULES_FILE" || true
    exit 1
fi

if [[ "$MODULES_CONTENT" =~ (^|$'\n')sch_cake ]]; then
    echo "✅ sch_cake module enabled"
else
    echo "❌ sch_cake module NOT enabled"
    grep "sch_cake" "$MODULES_FILE" || true
    exit 1
fi

echo "All performance checks passed!"
