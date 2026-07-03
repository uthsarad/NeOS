#!/bin/bash

echo "Verifying required airootfs files exist..."

REQUIRED_FILES=(
    "profile/airootfs/usr/local/bin/neos-driver-manager"
    "profile/airootfs/usr/local/bin/neos-autoupdate.sh"
    "profile/airootfs/usr/local/bin/neos-liveuser-setup"
    "profile/airootfs/etc/systemd/system/neos-driver-manager.service"
    "profile/airootfs/etc/systemd/system/neos-autoupdate.service"
    "profile/airootfs/etc/systemd/system/neos-autoupdate.timer"
    "profile/airootfs/etc/systemd/system/neos-liveuser-setup.service"
    "profile/airootfs/etc/sddm.conf.d/autologin.conf"
    "profile/airootfs/etc/skel/Desktop/welcome-neos.desktop"
    "profile/airootfs/etc/snapper/configs/root"
    "profile/airootfs/usr/share/neos/hooks/49-neos-snapshot-pre.hook"
    "profile/airootfs/usr/share/neos/hooks/99-neos-snapshot-post.hook"
    "profile/airootfs/etc/sysctl.d/90-neos-security.conf"
    "profile/airootfs/etc/default/grub"
    "profile/airootfs/etc/pacman.conf"
    "profile/airootfs/etc/calamares/settings.conf"
    "profile/airootfs/etc/calamares/modules/services-systemd.conf"
    "profile/airootfs/etc/systemd/zram-generator.conf"
    "profile/grub/grub.cfg"
    "profile/profiledef.sh"
    "profile/packages.x86_64"
)

ALL_PASSED=true

for FILE in "${REQUIRED_FILES[@]}"; do
    if [[ -f "$FILE" ]]; then
        echo "✅ $FILE"
    else
        echo "❌ Missing: $FILE"
        ALL_PASSED=false
    fi
done

# Verify services-systemd.conf enables required timers
SERVICES_FILE="profile/airootfs/etc/calamares/modules/services-systemd.conf"
REQUIRED_SERVICES=(
    "neos-autoupdate.timer"
    "neos-driver-manager"
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
PROFILE_FILE="profile/profiledef.sh"
REQUIRED_PERMS=(
    "neos-driver-manager"
    "neos-autoupdate.sh"
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


# Verify the live session behaves as installer media, not as a general-purpose live OS.
LIVEUSER_SETUP="profile/airootfs/usr/local/bin/neos-liveuser-setup"
INSTALLER_SHORTCUT="profile/airootfs/etc/skel/Desktop/welcome-neos.desktop"
INSTALLER_LAUNCHER="profile/airootfs/usr/local/bin/neos-welcome"

echo ""
echo "Verifying installer-media startup behavior..."

if grep -q 'welcome-neos.desktop' "$LIVEUSER_SETUP"; then
    echo "✅ Installer autostart is configured for the live user"
else
    echo "❌ Installer autostart is not configured for the live user"
    ALL_PASSED=false
fi

if grep -q 'Exec=/usr/local/bin/neos-welcome-app' "$INSTALLER_SHORTCUT"; then
    echo "✅ Desktop shortcut launches the welcome app"
else
    echo "❌ Desktop shortcut does not launch the welcome app"
    ALL_PASSED=false
fi

if grep -q 'calamares' "$INSTALLER_LAUNCHER"; then
    echo "✅ Installer launcher starts Calamares"
else
    echo "❌ Installer launcher does not start Calamares"
    ALL_PASSED=false
fi

# Verify pacman hooks have correct format (single [Action] per file)
echo ""
echo "Verifying pacman hook format..."

for HOOK in profile/airootfs/usr/share/neos/hooks/*.hook; do
    ACTION_COUNT=$(grep -c '^\[Action\]' "$HOOK")
    if [[ "$ACTION_COUNT" -eq 1 ]]; then
        echo "✅ $HOOK has exactly 1 [Action] section"
    else
        echo "❌ $HOOK has $ACTION_COUNT [Action] sections (expected 1)"
        ALL_PASSED=false
    fi
done

if [[ "$ALL_PASSED" == true ]]; then
    echo ""
    echo "All airootfs structure checks passed!"
    exit 0
else
    echo ""
    echo "One or more structure checks failed."
    exit 1
fi
