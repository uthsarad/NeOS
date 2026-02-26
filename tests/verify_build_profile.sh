#!/bin/bash
set -e

PROFILE_FILE="profiledef.sh"
WORKFLOW_FILE=".github/workflows/build-iso.yml"

echo "Verifying mkarchiso build profile configuration..."

# Verify workflow YAML is valid (prevents broken CI from heredoc/YAML conflicts)
if [ -f "$WORKFLOW_FILE" ]; then
    if python3 -c "import yaml" 2>/dev/null; then
        if python3 -c "
import yaml, sys
with open('$WORKFLOW_FILE') as f:
    yaml.safe_load(f)
" 2>/dev/null; then
            echo "✅ $WORKFLOW_FILE is valid YAML"
        else
            echo "❌ $WORKFLOW_FILE has YAML syntax errors (CI will fail with 0 jobs)"
            exit 1
        fi
    else
        echo "⚠️  PyYAML not installed, skipping YAML syntax check"
    fi
fi

# Verify profiledef.sh exists
if [ ! -f "$PROFILE_FILE" ]; then
    echo "❌ Missing $PROFILE_FILE"
    exit 1
fi

# Verify pacman_conf is set (prevents realpath: '' error in mkarchiso)
if grep -q 'pacman_conf=' "$PROFILE_FILE"; then
    echo "✅ pacman_conf is set in $PROFILE_FILE"
else
    echo "❌ pacman_conf is NOT set in $PROFILE_FILE (mkarchiso will fail with realpath error)"
    exit 1
fi

# Verify the referenced pacman.conf file exists
PACMAN_CONF=$(grep 'pacman_conf=' "$PROFILE_FILE" | head -1 | sed "s/.*pacman_conf=[\"']\{0,1\}\([^\"']*\)[\"']\{0,1\}/\1/")
if [ -n "$PACMAN_CONF" ] && [ -f "$PACMAN_CONF" ]; then
    echo "✅ Referenced pacman config '$PACMAN_CONF' exists"
else
    echo "❌ Referenced pacman config '$PACMAN_CONF' does not exist"
    exit 1
fi

# Verify pacman.conf uses DatabaseOptional (Required for mirrors without .db.sig)
if grep -q 'DatabaseOptional' "$PACMAN_CONF"; then
    echo "✅ $PACMAN_CONF uses DatabaseOptional"
else
    echo "❌ $PACMAN_CONF does not use DatabaseOptional"
    exit 1
fi

# Verify packages file exists for x86_64
if [ -f "packages.x86_64" ]; then
    echo "✅ packages.x86_64 exists"
else
    echo "❌ packages.x86_64 does not exist"
    exit 1
fi

# Verify bootstrap_packages exists (required by newer archiso)
if [ -f "bootstrap_packages.x86_64" ]; then
    echo "✅ bootstrap_packages.x86_64 file exists"
else
    echo "❌ bootstrap_packages.x86_64 file does not exist"
    exit 1
fi

if [ -f "bootstrap_packages.i686" ]; then
    echo "✅ bootstrap_packages.i686 file exists"
else
    echo "⚠️ bootstrap_packages.i686 file does not exist (recommended for i686 support)"
fi

if [ -f "bootstrap_packages.aarch64" ]; then
    echo "✅ bootstrap_packages.aarch64 file exists"
else
    echo "⚠️ bootstrap_packages.aarch64 file does not exist (recommended for aarch64 support)"
fi

# Verify boot modes are valid (extract quoted values from bootmodes= lines)
VALID_MODES="uefi.grub uefi.systemd-boot bios.syslinux bios.syslinux.mbr bios.syslinux.eltorito uefi-ia32.grub.esp uefi-x64.grub.esp uefi-x64.grub.eltorito"
if grep -q 'bootmodes=' "$PROFILE_FILE"; then
    for mode in $(grep 'bootmodes=' "$PROFILE_FILE" | grep -o '"[^"]*"' | tr -d '"'); do
        FOUND=false
        for valid in $VALID_MODES; do
            if [ "$mode" = "$valid" ]; then
                FOUND=true
                break
            fi
        done
        if [ "$FOUND" = true ]; then
            echo "✅ Boot mode '$mode' is valid"
        else
            echo "❌ Boot mode '$mode' is NOT valid (valid: $VALID_MODES)"
            exit 1
        fi
    done
fi

# Verify grub/grub.cfg exists (required for uefi.grub boot mode)
if grep -q 'uefi.grub' "$PROFILE_FILE"; then
    if [ -f "grub/grub.cfg" ]; then
        echo "✅ grub/grub.cfg exists (required for uefi.grub)"
    else
        echo "❌ grub/grub.cfg missing (required for uefi.grub boot mode)"
        exit 1
    fi
fi

echo "Build profile configuration checks passed."
