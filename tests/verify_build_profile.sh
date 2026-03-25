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
            echo ""
            echo "💡 How to fix:"
            echo "   - Review $WORKFLOW_FILE for indentation errors."
            echo "   - Ensure strings are properly quoted and lists are formatted correctly."
            exit 1
        fi
    else
        echo "⚠️  PyYAML not installed, skipping YAML syntax check"
    fi
fi

# Verify profiledef.sh exists
if [ ! -f "$PROFILE_FILE" ]; then
    echo "❌ Missing $PROFILE_FILE"
    echo ""
    echo "💡 How to fix:"
    echo "   - Ensure $PROFILE_FILE exists in the repository root."
    echo "   - Check if you are running this script from the correct directory."
    exit 1
fi

# Verify packages file exists for x86_64
if [ -f "packages.x86_64" ]; then
    echo "✅ packages.x86_64 exists"
else
    echo "❌ packages.x86_64 does not exist"
    echo ""
    echo "💡 How to fix:"
    echo "   - Create the packages.x86_64 file."
    echo "   - Ensure it contains a list of packages to install on the x86_64 architecture."
    exit 1
fi

# Verify bootstrap_packages exists (required by newer archiso)
if [ -f "bootstrap_packages.x86_64" ]; then
    echo "✅ bootstrap_packages.x86_64 file exists"
else
    echo "❌ bootstrap_packages.x86_64 file does not exist"
    echo ""
    echo "💡 How to fix:"
    echo "   - Create the bootstrap_packages.x86_64 file."
    echo "   - This file is required by mkarchiso to bootstrap the base system."
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


# Verify grub/grub.cfg exists (required for uefi.grub boot mode)
PROFILE_CONTENT=$(<"$PROFILE_FILE")
if [[ "$PROFILE_CONTENT" == *"uefi.grub"* ]]; then
    if [ -f "grub/grub.cfg" ]; then
        echo "✅ grub/grub.cfg exists (required for uefi.grub)"
    else
        echo "❌ grub/grub.cfg missing (required for uefi.grub boot mode)"
        echo ""
        echo "💡 How to fix:"
        echo "   - Provide grub/grub.cfg if you plan to support uefi.grub boot mode."
        echo "   - Remove 'uefi.grub' from bootmodes in $PROFILE_FILE if you do not."
        exit 1
    fi
fi

echo "Build profile configuration checks passed."

# Verify pacman.conf configuration for build environment
if [ -f "pacman.conf" ]; then
    # Bolt: Replace subprocess grep with native bash logic or read file lines if performance overhead becomes a concern during parallel validation.
    # Sentinel: The root pacman.conf requires 'DatabaseOptional' to unblock the build process for unsigned repos. Ensure this does not inadvertently leak to the installed system.
    has_db_req=false
    while read -r line; do
        if [[ "$line" =~ ^[[:space:]]*SigLevel[[:space:]]*=.*DatabaseRequired ]]; then
            has_db_req=true
            break
        fi
    done < pacman.conf
    if $has_db_req; then
        # Palette: Format error outputs clearly with multiline '💡 How to fix:' sections to assist developers when CI fails.
        echo "❌ pacman.conf contains build-blocking 'DatabaseRequired' setting."
        echo ""
        echo "💡 How to fix:"
        echo "   - Modify the global 'SigLevel' in the root 'pacman.conf' to 'Required DatabaseOptional'."
        echo "   - Ensure that the installed system config (airootfs/etc/pacman.conf) explicitly enforces 'DatabaseRequired'."
        exit 1
    else
        echo "✅ pacman.conf is correctly configured for the build environment (no global DatabaseRequired)."
    fi
else
    echo "❌ Root pacman.conf missing"
    echo ""
    echo "💡 How to fix:"
    echo "   - Ensure pacman.conf exists in the repository root."
    echo "   - This file is required to configure the build environment packages."
    exit 1
fi
