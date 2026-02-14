#!/bin/bash

echo "Verifying required airootfs files exist..."

REQUIRED_FILES=(
    "airootfs/usr/local/bin/neos-driver-manager"
    "airootfs/usr/local/bin/neos-performance-tweaks"
    "airootfs/usr/local/bin/neos-autoupdate.sh"
    "airootfs/usr/local/bin/neos-installer-partition.sh"
    "airootfs/usr/local/bin/neos-liveuser-setup"
    "airootfs/etc/systemd/system/neos-driver-manager.service"
    "airootfs/etc/systemd/system/neos-performance-tweaks.service"
    "airootfs/etc/systemd/system/neos-autoupdate.service"
    "airootfs/etc/systemd/system/neos-autoupdate.timer"
    "airootfs/etc/systemd/system/neos-liveuser-setup.service"
    "airootfs/etc/sddm.conf.d/autologin.conf"
    "airootfs/etc/snapper/configs/root"
    "airootfs/etc/pacman.d/hooks/49-neos-snapshot-pre.hook"
    "airootfs/etc/pacman.d/hooks/99-neos-snapshot-post.hook"
    "airootfs/etc/sysctl.d/90-neos-security.conf"
    "airootfs/etc/sysctl.d/99-neos-performance.conf"
    "airootfs/etc/default/grub"
    "airootfs/etc/pacman.conf"
    "airootfs/etc/calamares/settings.conf"
    "airootfs/etc/calamares/modules/services-systemd.conf"
    "airootfs/etc/systemd/zram-generator.conf"
    "grub/grub.cfg"
    "profiledef.sh"
    "packages.x86_64"
)

ALL_PASSED=true

for FILE in "${REQUIRED_FILES[@]}"; do
    if [ -f "$FILE" ]; then
        echo "✅ $FILE"
    else
        echo "❌ Missing: $FILE"
        ALL_PASSED=false
    fi
done

# Verify services-systemd.conf enables required timers
SERVICES_FILE="airootfs/etc/calamares/modules/services-systemd.conf"
REQUIRED_SERVICES=(
    "neos-autoupdate.timer"
    "neos-driver-manager"
    "neos-performance-tweaks"
    "fstrim.timer"
    "ufw"
)

echo ""
echo "Verifying enabled services in $SERVICES_FILE..."

for SVC in "${REQUIRED_SERVICES[@]}"; do
    if grep -q "$SVC" "$SERVICES_FILE"; then
        echo "✅ Service '$SVC' enabled"
    else
        echo "❌ Service '$SVC' NOT enabled"
        ALL_PASSED=false
    fi
done

# Verify profiledef.sh has permissions for executable scripts
PROFILE_FILE="profiledef.sh"
REQUIRED_PERMS=(
    "neos-driver-manager"
    "neos-performance-tweaks"
    "neos-autoupdate.sh"
    "neos-installer-partition.sh"
    "neos-liveuser-setup"
)

echo ""
echo "Verifying file permissions in $PROFILE_FILE..."

for PERM in "${REQUIRED_PERMS[@]}"; do
    if grep -q "$PERM" "$PROFILE_FILE"; then
        echo "✅ Permission entry for '$PERM' found"
    else
        echo "❌ Permission entry for '$PERM' NOT found"
        ALL_PASSED=false
    fi
done

# Verify pacman hooks have correct format (single [Action] per file)
echo ""
echo "Verifying pacman hook format..."

for HOOK in airootfs/etc/pacman.d/hooks/*.hook; do
    ACTION_COUNT=$(grep -c '^\[Action\]' "$HOOK")
    if [ "$ACTION_COUNT" -eq 1 ]; then
        echo "✅ $HOOK has exactly 1 [Action] section"
    else
        echo "❌ $HOOK has $ACTION_COUNT [Action] sections (expected 1)"
        ALL_PASSED=false
    fi
done

if [ "$ALL_PASSED" = true ]; then
    echo ""
    echo "All airootfs structure checks passed!"
    exit 0
else
    echo ""
    echo "One or more structure checks failed."
    exit 1
fi
