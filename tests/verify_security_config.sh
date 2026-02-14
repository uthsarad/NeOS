#!/bin/bash
set -e

CONFIG_FILE="airootfs/etc/sysctl.d/90-neos-security.conf"

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

# Check for kernel.sysrq
if grep -q "kernel.sysrq = 0" "$CONFIG_FILE"; then
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

# Sentinel: Check for SigLevel = Required DatabaseRequired in airootfs/etc/pacman.conf
PACMAN_CONF="airootfs/etc/pacman.conf"
echo "Verifying security configuration in $PACMAN_CONF..."

if grep -qE "^SigLevel\s*=\s*Required\s+DatabaseRequired" "$PACMAN_CONF"; then
    echo "✅ SigLevel = Required DatabaseRequired found"
else
    echo "❌ SigLevel = Required DatabaseRequired NOT found in $PACMAN_CONF"
    exit 1
fi

echo "All security checks passed!"
