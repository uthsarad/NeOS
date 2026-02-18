#!/bin/bash
set -e

# --- Calamares Installer Config Verification ---
CONFIG_FILE="airootfs/etc/calamares/modules/fstab.conf"

echo "Verifying performance configuration in $CONFIG_FILE..."

# Check for space_cache=v2 in btrfs mount options
# We expect it alongside compress=zstd to ensure it's in the main mountOptions block, not just ssdExtraMountOptions
if grep -E "btrfs:.*compress=zstd.*space_cache=v2" "$CONFIG_FILE"; then
    echo "✅ space_cache=v2 found in main Btrfs mount options"
else
    echo "❌ space_cache=v2 NOT found in main Btrfs mount options (or not correctly placed)"
    # Show context for debugging
    grep "btrfs:" "$CONFIG_FILE" || true
    exit 1
fi

# --- System Performance Config Verification ---
SYSCTL_FILE="airootfs/etc/sysctl.d/99-neos-performance.conf"

echo "Verifying sysctl performance configuration in $SYSCTL_FILE..."

if [ ! -f "$SYSCTL_FILE" ]; then
    echo "❌ Missing performance config file: $SYSCTL_FILE"
    exit 1
fi

# Verify vm.swappiness=180
# Use grep -q for quiet check, but echo result
if grep -q "vm.swappiness.*=.*180" "$SYSCTL_FILE"; then
    echo "✅ vm.swappiness set to 180 (aggressive swap to ZRAM)"
else
    echo "❌ vm.swappiness NOT set to 180"
    grep "vm.swappiness" "$SYSCTL_FILE" || true
    exit 1
fi

# Verify vm.page-cluster=0
if grep -q "vm.page-cluster.*=.*0" "$SYSCTL_FILE"; then
    echo "✅ vm.page-cluster set to 0 (optimized for ZRAM)"
else
    echo "❌ vm.page-cluster NOT set to 0"
    grep "vm.page-cluster" "$SYSCTL_FILE" || true
    exit 1
fi

# Verify vm.vfs_cache_pressure=50
if grep -q "vm.vfs_cache_pressure.*=.*50" "$SYSCTL_FILE"; then
    echo "✅ vm.vfs_cache_pressure set to 50 (prefer cache retention)"
else
    echo "❌ vm.vfs_cache_pressure NOT set to 50"
    grep "vm.vfs_cache_pressure" "$SYSCTL_FILE" || true
    exit 1
fi

# Verify vm.max_map_count=2147483642
if grep -q "vm.max_map_count.*=.*2147483642" "$SYSCTL_FILE"; then
    echo "✅ vm.max_map_count set to 2147483642 (Steam/Proton optimization)"
else
    echo "❌ vm.max_map_count NOT set to 2147483642"
    grep "vm.max_map_count" "$SYSCTL_FILE" || true
    exit 1
fi

# Verify net.core.default_qdisc=cake
if grep -q "net.core.default_qdisc.*=.*cake" "$SYSCTL_FILE"; then
    echo "✅ net.core.default_qdisc set to cake (bufferbloat mitigation)"
else
    echo "❌ net.core.default_qdisc NOT set to cake"
    grep "net.core.default_qdisc" "$SYSCTL_FILE" || true
    exit 1
fi

# Verify net.ipv4.tcp_congestion_control=bbr
if grep -q "net.ipv4.tcp_congestion_control.*=.*bbr" "$SYSCTL_FILE"; then
    echo "✅ net.ipv4.tcp_congestion_control set to bbr (BBR congestion control)"
else
    echo "❌ net.ipv4.tcp_congestion_control NOT set to bbr"
    grep "net.ipv4.tcp_congestion_control" "$SYSCTL_FILE" || true
    exit 1
fi

# --- Network Modules Verification ---
MODULES_FILE="airootfs/etc/modules-load.d/neos-networking.conf"
echo "Verifying network modules in $MODULES_FILE..."

if [ ! -f "$MODULES_FILE" ]; then
    echo "❌ Missing network modules file: $MODULES_FILE"
    exit 1
fi

if grep -q "tcp_bbr" "$MODULES_FILE"; then
    echo "✅ tcp_bbr module configured for loading"
else
    echo "❌ tcp_bbr module MISSING from $MODULES_FILE"
    exit 1
fi

if grep -q "sch_cake" "$MODULES_FILE"; then
    echo "✅ sch_cake module configured for loading"
else
    echo "❌ sch_cake module MISSING from $MODULES_FILE"
    exit 1
fi

echo "All performance checks passed!"
