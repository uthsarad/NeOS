#!/bin/bash

echo "Verifying required airootfs files exist..."

REQUIRED_FILES=(
    "profile/airootfs/usr/local/bin/neos-driver-manager"
    "profile/airootfs/usr/local/bin/neos-autoupdate.sh"
    "profile/airootfs/usr/local/bin/neos-liveuser-setup"
    "profile/airootfs/usr/local/bin/chcon"
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
    "profile/airootfs/usr/local/bin/neos-display-sync"
    "profile/airootfs/usr/local/bin/neos-autoinstall"
    "profile/airootfs/usr/local/bin/neos-doctor"
)

ALL_PASSED=true

for FILE in "${REQUIRED_FILES[@]}"; do
    if [[ -f "$FILE" ]]; then
        echo "  [PASS] $FILE"
    else
        echo "[FAIL] Missing: $FILE"
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

SERVICES_CONTENT=$(<"$SERVICES_FILE")
for SVC in "${REQUIRED_SERVICES[@]}"; do
    if [[ "$SERVICES_CONTENT" == *"$SVC"* ]]; then
        echo "  [PASS] Service '$SVC' enabled"
    else
        echo "[FAIL] Service '$SVC' NOT enabled"
        ALL_PASSED=false
    fi
done

# Verify profiledef.sh has permissions for executable scripts
PROFILE_FILE="profile/profiledef.sh"
REQUIRED_PERMS=(
    "neos-driver-manager"
    "neos-autoupdate.sh"
    "neos-liveuser-setup"
    "chcon"
    "neos-display-sync"
    "neos-autoinstall"
    "neos-doctor"
)

echo ""
echo "Verifying file permissions in $PROFILE_FILE..."

PROFILE_CONTENT=$(<"$PROFILE_FILE")
for PERM in "${REQUIRED_PERMS[@]}"; do
    if [[ "$PROFILE_CONTENT" == *"$PERM"* ]]; then
        echo "  [PASS] Permission entry for '$PERM' found"
    else
        echo "[FAIL] Permission entry for '$PERM' NOT found"
        ALL_PASSED=false
    fi
done


# Verify the live session behaves as installer media, not as a general-purpose live OS.
LIVEUSER_SETUP="profile/airootfs/usr/local/bin/neos-liveuser-setup"
INSTALLER_SHORTCUT="profile/airootfs/etc/skel/Desktop/welcome-neos.desktop"
INSTALLER_LAUNCHER="profile/airootfs/usr/local/bin/neos-welcome"

echo ""
echo "Verifying installer-media startup behavior..."

LIVEUSER_CONTENT=$(<"$LIVEUSER_SETUP")
if [[ "$LIVEUSER_CONTENT" == *'welcome-neos.desktop'* ]]; then
    echo "[PASS] Installer autostart is configured for the live user"
else
    echo "[FAIL] Installer autostart is not configured for the live user"
    ALL_PASSED=false
fi

INSTALLER_SHORTCUT_CONTENT=$(<"$INSTALLER_SHORTCUT")
if [[ "$INSTALLER_SHORTCUT_CONTENT" == *'Exec=/usr/local/bin/neos-welcome-app'* ]]; then
    echo "[PASS] Desktop shortcut launches the welcome app"
else
    echo "[FAIL] Desktop shortcut does not launch the welcome app"
    ALL_PASSED=false
fi

INSTALLER_LAUNCHER_CONTENT=$(<"$INSTALLER_LAUNCHER")
if [[ "$INSTALLER_LAUNCHER_CONTENT" == *'calamares'* ]]; then
    echo "[PASS] Installer launcher starts Calamares"
else
    echo "[FAIL] Installer launcher does not start Calamares"
    ALL_PASSED=false
fi

# Verify pacman hooks have correct format (single [Action] per file)
echo ""
echo "Verifying pacman hook format..."

for HOOK in profile/airootfs/usr/share/neos/hooks/*.hook; do
    ACTION_COUNT=$(grep -c '^\[Action\]' "$HOOK")
    if [[ "$ACTION_COUNT" -eq 1 ]]; then
        echo "  [PASS] $HOOK has exactly 1 [Action] section"
    else
        echo "[FAIL] $HOOK has $ACTION_COUNT [Action] sections (expected 1)"
        ALL_PASSED=false
    fi
done

# The Omarchy rebrand renamed omarchy/ trees to neos/ but left byte-identical
# omarchy/ copies inside them, which landed in every new user's home
# (reports/v2026.10.02/00-improvement-plan.md C2).
echo ""
echo "Verifying no leftover omarchy/ overlay paths..."

LEFTOVER="$(find profile/airootfs -ipath '*omarchy*' -print -quit)"
if [[ -z "$LEFTOVER" ]]; then
    echo "  [PASS] no omarchy-named paths in the overlay"
else
    echo "[FAIL] leftover pre-rebrand path in the overlay: $LEFTOVER"
    ALL_PASSED=false
fi

# mkarchiso copies the overlay into the root BEFORE pacstrap, so an overlay
# file that a package also owns aborts the ISO build with "conflicting files".
# These are the ones the Omarchy import captured from an installed system
# (build failure on uthsarad/NeOS#1068). With pacman available, also ask the
# files database about every overlay file.
echo ""
echo "Verifying the overlay does not ship package-owned files..."

PACKAGE_OWNED=(
    "usr/share/icons/hicolor/index.theme|hicolor-icon-theme"
    "etc/skel/.screenrc|screen"
    "etc/skel/.zshrc|grml-zsh-config"
    "usr/share/icons/hicolor/48x48/apps/lftp-icon.png|lftp"
    "usr/share/icons/hicolor/22x22/apps/ModemManager.png|modemmanager"
    "usr/share/icons/hicolor/48x48/apps/gvim.png|vim"
    "usr/share/icons/locolor/16x16/apps/gvim.png|vim"
    "usr/share/icons/locolor/32x32/apps/gvim.png|vim"
)
OWNED_FOUND=0
for entry in "${PACKAGE_OWNED[@]}"; do
    path="${entry%%|*}"
    if [[ -e "profile/airootfs/$path" ]]; then
        echo "[FAIL] profile/airootfs/$path is owned by package '${entry#*|}' (mkarchiso: conflicting files)"
        OWNED_FOUND=1
    fi
done
if command -v pacman >/dev/null 2>&1 && pacman -F --help >/dev/null 2>&1 \
    && [[ -n "$(find /var/lib/pacman/sync -name '*.files' -print -quit 2>/dev/null)" ]]; then
    while IFS= read -r rel; do
        owner="$(pacman -Fq "/$rel" 2>/dev/null | head -1 || true)"
        if [[ -n "$owner" ]] && grep -qx "${owner##*/}" profile/packages.x86_64; then
            echo "[FAIL] profile/airootfs/$rel is also shipped by package '${owner##*/}'"
            OWNED_FOUND=1
        fi
    done < <(cd profile/airootfs && find . -type f -printf '%P\n')
fi
if (( OWNED_FOUND )); then
    ALL_PASSED=false
else
    echo "  [PASS] no known package-owned files in the overlay"
fi

# A new user's first interactive bash must start cleanly. The Omarchy .bashrc
# sourced "$NEOS_PATH/default/bash/rc" with NEOS_PATH unset on NeOS, so every
# shell printed an error (reports/v2026.10.02/02-review-report.md).
echo ""
echo "Verifying /etc/skel/.bashrc starts cleanly..."

SKEL_HOME="$(mktemp -d)"
# Without a TTY, bash -i always reports missing job control; ignore just that.
BASHRC_ERR="$(HOME="$SKEL_HOME" bash --noprofile --rcfile profile/airootfs/etc/skel/.bashrc -i -c true 2>&1 >/dev/null \
    | grep -vE 'cannot set terminal process group|no job control in this shell' || true)"
rm -rf "$SKEL_HOME"
if [[ -z "$BASHRC_ERR" ]]; then
    echo "  [PASS] interactive bash with the skel .bashrc prints no errors"
else
    echo "[FAIL] interactive bash with the skel .bashrc printed: $BASHRC_ERR"
    ALL_PASSED=false
fi

if [[ "$ALL_PASSED" == true ]]; then
    echo ""
    echo "All airootfs structure checks passed!"
    exit 0
else
    echo ""
    echo "One or more structure checks failed."
    exit 1
fi
